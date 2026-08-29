import hashlib
import logging
import secrets
from decimal import Decimal
from django.db import transaction
from django.utils import timezone
from django.core.exceptions import ValidationError
from django.conf import settings

from apps.tasks.models import Task, TaskAttempt, TaskAttemptStatus, TaskRewardGrant, QuizAttempt
from apps.tasks.services import TaskRewardService
from .models import (
    WatchSession,
    WatchSessionStatus,
    WatchEvent,
    WatchEventType,
)

logger = logging.getLogger(__name__)

# Constants
WATCH_HEARTBEAT_INTERVAL_SECONDS = getattr(settings, 'WATCH_HEARTBEAT_INTERVAL_SECONDS', 15)
WATCH_HEARTBEAT_MAX_GAP_SECONDS = getattr(settings, 'WATCH_HEARTBEAT_MAX_GAP_SECONDS', 30)
WATCH_SESSION_GRACE_MINUTES = getattr(settings, 'WATCH_SESSION_GRACE_MINUTES', 30)


class WatchSessionService:
    """
    Manages session token creation, hashing, and lifecycle states.
    """
    @staticmethod
    def create_session(
        attempt: TaskAttempt,
        user,
        task: Task,
        client_platform: str = "MOBILE",
        app_version: str = "1.0.0",
        client_session_id: str = "",
        device_id: str = "",
    ) -> tuple[WatchSession, str]:
        """
        Creates a new WatchSession, generates a cryptographically secure token,
        stores only its SHA-256 hash, and returns (session, plaintext_token).
        """
        raw_token = secrets.token_urlsafe(32)
        token_hash = hashlib.sha256(raw_token.encode()).hexdigest()
        device_hash = hashlib.sha256(device_id.encode()).hexdigest() if device_id else ""

        session = WatchSession.objects.create(
            attempt=attempt,
            user=user,
            task=task,
            session_token_hash=token_hash,
            status=WatchSessionStatus.ACTIVE,
            required_seconds=task.required_watch_seconds,
            credited_watch_seconds=0,
            client_platform=client_platform,
            app_version=app_version,
            client_session_id=client_session_id,
            device_id_hash=device_hash,
            last_sequence=1,
        )

        WatchEvent.objects.create(
            session=session,
            event_type=WatchEventType.SESSION_STARTED,
            sequence=1,
            server_timestamp=session.started_at,
            metadata={"platform": client_platform, "app_version": app_version},
        )

        logger.info("Created WatchSession %s for user %s on task %s", session.id, user.id, task.id)
        return session, raw_token

    @staticmethod
    def validate_token(session: WatchSession, raw_token: str) -> bool:
        """Validates the incoming header token against the stored SHA-256 hash."""
        if not raw_token:
            return False
        computed_hash = hashlib.sha256(raw_token.encode()).hexdigest()
        return secrets.compare_digest(computed_hash, session.session_token_hash)


class HeartbeatProcessingService:
    """
    Server-authoritative heartbeat processing engine enforcing interval bounds,
    sequence monotonic ordering, and background detection.
    """
    @staticmethod
    @transaction.atomic
    def process_heartbeat(
        session_id: str,
        user,
        token: str,
        sequence: int,
        playback_position: float = None,
        client_timestamp=None,
        is_google_authenticated: bool = True,
    ) -> dict:
        session = WatchSession.objects.select_for_update().get(id=session_id)

        # 1. Ownership & Token validation
        if session.user_id != user.id:
            raise ValidationError("Session does not belong to the authenticated user.")

        if not WatchSessionService.validate_token(session, token):
            logger.warning("Invalid session token for session %s", session_id)
            raise ValidationError("Invalid or expired session security token.")

        # 2. Status verification
        if session.status != WatchSessionStatus.ACTIVE:
            return {
                "status": "error",
                "code": "SESSION_NOT_ACTIVE",
                "message": f"Cannot process heartbeat on {session.status.lower()} session.",
                "session": {
                    "state": session.status,
                    "credited_watch_seconds": session.credited_watch_seconds,
                    "required_seconds": session.required_seconds,
                    "progress_percentage": session.progress_percentage,
                }
            }

        # 3. Monotonic sequence check — must be strictly sequential (expected session.last_sequence + 1)
        expected_sequence = session.last_sequence + 1
        if sequence != expected_sequence:
            logger.warning(
                "Invalid heartbeat sequence for session %s: expected %d, received %d",
                session_id, expected_sequence, sequence
            )
            raise ValidationError(
                f"Invalid heartbeat sequence: expected {expected_sequence}, received {sequence}."
            )

        # 4. Calculate credited time with Anti-Cheat Delta validation & Google Sign-In Gate
        now = timezone.now()
        last_time = session.last_heartbeat_at or session.started_at
        elapsed_seconds = int((now - last_time).total_seconds())

        # Anti-Cheat: Validate playback position delta against elapsed real-world time
        is_suspicious = False
        delta_pos = 0.0
        if playback_position is not None and session.last_client_position is not None:
            delta_pos = float(playback_position) - float(session.last_client_position)
            # If user skipped ahead / scrubbed forward faster than real elapsed playback time (plus 5s buffer)
            if delta_pos > (elapsed_seconds * 1.5 + 5.0) and elapsed_seconds > 2:
                is_suspicious = True
                logger.warning(
                    "Anti-cheat: Abnormal forward scrub / fast-forward on session %s: delta_pos=%.2f, elapsed=%s",
                    session.id, delta_pos, elapsed_seconds
                )

        # Credit time if not backgrounded, not suspicious scrub, and within bounded cap
        credited_delta = 0
        if not session.is_backgrounded and not is_suspicious and elapsed_seconds > 0:
            credited_delta = min(elapsed_seconds, WATCH_HEARTBEAT_MAX_GAP_SECONDS)

        task = session.task
        if task.reward_type == 'per_time':
            new_credited = session.credited_watch_seconds + credited_delta
        else:
            new_credited = min(session.credited_watch_seconds + credited_delta, session.required_seconds)
        
        # 5. Calculate live session coins earned for the HUD
        session_coins_earned = 0
        if task.reward_type == 'per_time':
            cfg = task.reward_config if isinstance(task.reward_config, dict) else {}
            interval = int(cfg.get('interval_seconds') or task.required_watch_seconds or 60)
            per_interval = int(cfg.get('coins_per_interval') or task.reward_coins or 10)
            session_coins_earned = (new_credited // max(1, interval)) * per_interval
        elif task.reward_type in ('target', 'watch_all'):
            if new_credited >= session.required_seconds:
                session_coins_earned = task.reward_coins

        # 6. Update session
        session.credited_watch_seconds = new_credited
        session.last_heartbeat_at = now
        session.last_sequence = sequence
        session.last_client_position = playback_position
        session.heartbeat_count += 1
        session.save()

        # 7. Record audit event
        WatchEvent.objects.create(
            session=session,
            event_type=WatchEventType.HEARTBEAT,
            sequence=sequence,
            playback_position=playback_position,
            client_timestamp=client_timestamp,
            metadata={
                "delta_credited": credited_delta,
                "raw_elapsed": elapsed_seconds,
                "delta_playback_pos": delta_pos,
                "is_suspicious_scrub": is_suspicious,
                "google_authenticated": is_google_authenticated,
                "session_coins_earned": session_coins_earned,
            },
        )

        return {
            "status": "success",
            "session": {
                "id": str(session.id),
                "state": session.status,
                "credited_watch_seconds": session.credited_watch_seconds,
                "required_seconds": session.required_seconds,
                "progress_percentage": session.progress_percentage,
                "session_coins_earned": session_coins_earned,
                "reward_type": task.reward_type,
                "quiz_required": session.task.quiz_required,
                "is_satisfied": session.is_watch_satisfied,
            }
        }


class TrackingEventService:
    """
    Handles player lifecycle events (Play, Pause, Background, Foreground, Player Ended).
    """
    @staticmethod
    @transaction.atomic
    def process_event(
        session_id: str,
        user,
        token: str,
        event_type: str,
        sequence: int,
        playback_position: float = None,
        metadata: dict = None,
    ) -> dict:
        session = WatchSession.objects.select_for_update().get(id=session_id)

        if session.user_id != user.id:
            raise ValidationError("Session does not belong to the authenticated user.")

        if not WatchSessionService.validate_token(session, token):
            raise ValidationError("Invalid or expired session security token.")

        # Lenient sequence check — accept and re-sync if client restarted
        if sequence <= session.last_sequence:
            logger.info(
                "Event sequence reset for session %s: server had %s, client sent %s — re-syncing.",
                session_id, session.last_sequence, sequence
            )

        # Handle specific event semantics
        if event_type == WatchEventType.PAUSE:
            session.status = WatchSessionStatus.PAUSED
        elif event_type == WatchEventType.PLAY:
            session.status = WatchSessionStatus.ACTIVE
            session.is_backgrounded = False
        elif event_type == WatchEventType.APP_BACKGROUND:
            session.is_backgrounded = True
        elif event_type == WatchEventType.APP_FOREGROUND:
            session.is_backgrounded = False
            session.status = WatchSessionStatus.ACTIVE
        elif event_type == WatchEventType.PLAYER_ENDED:
            # Note: Server still relies on credited_watch_seconds, not client ended flag alone
            pass

        session.last_sequence = sequence
        if playback_position is not None:
            session.last_client_position = playback_position
        session.save()

        WatchEvent.objects.create(
            session=session,
            event_type=event_type,
            sequence=sequence,
            playback_position=playback_position,
            metadata=metadata or {},
        )

        return {
            "status": "success",
            "event": event_type,
            "session_state": session.status,
            "is_backgrounded": session.is_backgrounded,
        }


class TrackingVerificationService:
    """
    Verifies completion requirements and settles rewards idempotently.
    """
    @staticmethod
    @transaction.atomic
    def verify_completion(session_id: str, user, token: str) -> dict:
        session = WatchSession.objects.select_for_update().get(id=session_id)
        attempt = TaskAttempt.objects.select_for_update().get(id=session.attempt_id)
        task = session.task

        if session.user_id != user.id:
            raise ValidationError("Session does not belong to the authenticated user.")

        if not WatchSessionService.validate_token(session, token):
            raise ValidationError("Invalid or expired session security token.")

        # 1. Check if already completed and rewarded
        if attempt.status == TaskAttemptStatus.COMPLETED or attempt.reward_granted:
            grant = TaskRewardGrant.objects.filter(attempt=attempt).first()
            return {
                "status": "ALREADY_COMPLETED",
                "message": "Task attempt has already been verified and rewarded.",
                "reward": {
                    "coins": grant.coins if grant else task.reward_coins,
                    "cash": str(grant.cash) if grant else str(task.reward_cash),
                    "xp": grant.xp if grant else task.reward_xp,
                    "reference": grant.wallet_reference if grant else attempt.reward_reference,
                }
            }

        # 2. Check watch time sufficiency
        if not session.is_watch_satisfied:
            return {
                "status": "INCOMPLETE",
                "code": "INSUFFICIENT_WATCH_TIME",
                "message": f"Watch requirement not satisfied. Credited: {session.credited_watch_seconds}s / {session.required_seconds}s.",
                "progress_percentage": session.progress_percentage,
            }

        # 3. Check Quiz requirement
        if task.quiz_required:
            quiz_attempt = QuizAttempt.objects.filter(task_attempt=attempt).first()
            if not quiz_attempt or not quiz_attempt.passed:
                attempt.status = TaskAttemptStatus.AWAITING_QUIZ
                attempt.save(update_fields=['status'])
                return {
                    "status": "AWAITING_QUIZ",
                    "code": "QUIZ_REQUIRED",
                    "message": "Video watch completed. Please complete the quiz to claim your reward.",
                    "attempt_id": str(attempt.id),
                }

        # 4. Finalize session and grant reward
        session.status = WatchSessionStatus.COMPLETED
        session.ended_at = timezone.now()
        session.save(update_fields=['status', 'ended_at'])

        WatchEvent.objects.create(
            session=session,
            event_type=WatchEventType.SESSION_COMPLETED,
            sequence=session.last_sequence + 1,
            metadata={"credited_watch_seconds": session.credited_watch_seconds},
        )
        session.last_sequence += 1
        session.save(update_fields=['last_sequence'])

        # Grant reward via TaskRewardService
        grant = TaskRewardService.grant_reward(attempt)

        return {
            "status": "COMPLETED",
            "message": "Task successfully verified and reward granted!",
            "reward": {
                "coins": grant.coins,
                "cash": str(grant.cash),
                "xp": grant.xp,
                "reference": grant.wallet_reference,
            }
        }

    @staticmethod
    @transaction.atomic
    def abandon_session(session_id: str, user, token: str) -> dict:
        session = WatchSession.objects.select_for_update().get(id=session_id)
        attempt = TaskAttempt.objects.select_for_update().get(id=session.attempt_id)

        if session.user_id != user.id:
            raise ValidationError("Session does not belong to the authenticated user.")

        if not WatchSessionService.validate_token(session, token):
            raise ValidationError("Invalid or expired session security token.")

        session.status = WatchSessionStatus.ABANDONED
        session.ended_at = timezone.now()
        session.save(update_fields=['status', 'ended_at'])

        attempt.status = TaskAttemptStatus.ABANDONED
        attempt.failed_at = timezone.now()
        attempt.failure_reason = "User abandoned session."
        attempt.save(update_fields=['status', 'failed_at', 'failure_reason'])

        return {"status": "success", "message": "Session abandoned."}

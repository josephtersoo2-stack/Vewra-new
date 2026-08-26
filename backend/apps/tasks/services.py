import uuid
import logging
from decimal import Decimal
from django.db import transaction
from django.db.models import F
from django.utils import timezone
from django.core.exceptions import ValidationError
from django.contrib.auth import get_user_model
from apps.wallet.services import WalletService
from apps.wallet.models import CoinTransactionType, CashTransactionType
from .models import (
    Task,
    TaskType,
    TaskStatus,
    TaskAttempt,
    TaskAttemptStatus,
    TaskRewardGrant,
    QuizQuestion,
    QuizAttempt,
    QuizAnswer,
)

logger = logging.getLogger(__name__)
User = get_user_model()

class TaskEligibilityService:
    """
    Evaluates server-authoritative eligibility for a user attempting a task.
    """
    @staticmethod
    def check(user, task: Task) -> dict:
        now = timezone.now()
        reasons = []
        
        # 1. Account active check
        account_active = user.is_authenticated and user.is_active
        if not account_active:
            reasons.append("User account is inactive or not authenticated.")

        # 2. Task active status
        task_active = task.status == TaskStatus.ACTIVE
        if not task_active:
            reasons.append(f"Task is currently {task.status.lower()}.")

        # 3. Schedule constraints
        schedule = True
        if task.starts_at and now < task.starts_at:
            schedule = False
            reasons.append("Task has not started yet.")
        if task.expires_at and now > task.expires_at:
            schedule = False
            reasons.append("Task has expired.")

        # 4. Global Capacity
        capacity = True
        if task.total_completion_limit is not None and task.total_completions >= task.total_completion_limit:
            capacity = False
            reasons.append("Task global completion limit reached.")

        # 5. User Level threshold
        profile = getattr(user, 'profile', None)
        user_level = getattr(profile, 'level', 1) if profile else 1
        level_ok = user_level >= task.minimum_level
        if not level_ok:
            reasons.append(f"Requires minimum level {task.minimum_level} (your level: {user_level}).")

        # 6. Trust Score threshold
        user_trust = getattr(profile, 'trust_score', 80) if profile else 80
        trust_ok = user_trust >= task.minimum_trust_score
        if not trust_ok:
            reasons.append(f"Requires minimum trust score {task.minimum_trust_score} (your score: {user_trust}).")

        # 7. Verification / KYC requirement
        verification_ok = True
        if task.verification_required:
            ver_status = getattr(user, 'verification_status', 'Basic')
            ver_record = getattr(user, 'verification', None)
            is_verified = (ver_status in ['Verified', 'Trusted']) or (ver_record and ver_record.status == 'APPROVED')
            if not is_verified:
                verification_ok = False
                reasons.append("KYC identity verification required to unlock this task.")

        # 8. Daily User Limit
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        today_completions = TaskAttempt.objects.filter(
            user=user,
            task=task,
            status=TaskAttemptStatus.COMPLETED,
            completed_at__gte=today_start
        ).count()
        daily_ok = today_completions < task.daily_user_limit
        if not daily_ok:
            reasons.append(f"Daily limit of {task.daily_user_limit} completion(s) reached for today.")

        # 9. Repeat / Active Attempt Rule
        repeat_ok = True
        active_attempt = TaskAttempt.objects.filter(
            user=user,
            task=task,
            status__in=[
                TaskAttemptStatus.CREATED,
                TaskAttemptStatus.IN_PROGRESS,
                TaskAttemptStatus.AWAITING_QUIZ,
                TaskAttemptStatus.VERIFYING,
            ]
        ).first()

        eligible = (
            account_active and
            task_active and
            schedule and
            capacity and
            level_ok and
            trust_ok and
            verification_ok and
            daily_ok
        )

        return {
            "eligible": eligible,
            "reasons": reasons,
            "requirements": {
                "account_active": account_active,
                "task_active": task_active,
                "schedule": schedule,
                "capacity": capacity,
                "level": level_ok,
                "trust_score": trust_ok,
                "verification": verification_ok,
                "daily_limit": daily_ok,
                "repeat_rule": repeat_ok,
            },
            "active_attempt_id": str(active_attempt.id) if active_attempt else None,
        }


class TaskRewardService:
    """
    Handles idempotent task reward calculation, wallet ledger integration, and XP granting.
    """
    @staticmethod
    @transaction.atomic
    def grant_reward(attempt: TaskAttempt) -> TaskRewardGrant:
        """
        Atomically grant rewards for a verified task attempt.
        Idempotent: If reward was already granted, returns existing grant without duplicate credit.
        """
        # Lock attempt
        attempt = TaskAttempt.objects.select_for_update().get(id=attempt.id)
        task = Task.objects.select_for_update().get(id=attempt.task_id)

        # Check existing grant
        existing_grant = TaskRewardGrant.objects.filter(attempt=attempt).first()
        if existing_grant or attempt.reward_granted:
            logger.info("Reward already granted for attempt %s, returning existing grant.", attempt.id)
            return existing_grant

        wallet_ref = f"TASK-{attempt.id}"

        # 1. Credit Coins via WalletService
        if task.reward_coins > 0:
            WalletService.credit_coins(
                user=attempt.user,
                amount=task.reward_coins,
                transaction_type=CoinTransactionType.REWARD,
                reference=wallet_ref,
                description=f"Task reward: {task.title}",
            )

        # 2. Credit Cash if applicable
        if task.reward_cash > Decimal('0.00'):
            WalletService.credit_cash(
                user=attempt.user,
                amount=task.reward_cash,
                transaction_type=CashTransactionType.REWARD,
                reference=wallet_ref,
                description=f"Task fiat reward: {task.title}",
            )

        # 3. Grant XP
        if task.reward_xp > 0:
            TaskRewardService.grant_xp(
                user=attempt.user,
                amount=task.reward_xp,
                reason=f"Task completed: {task.title}",
                reference=wallet_ref,
            )

        # 4. Create TaskRewardGrant
        grant = TaskRewardGrant.objects.create(
            user=attempt.user,
            task=task,
            attempt=attempt,
            coins=task.reward_coins,
            cash=task.reward_cash,
            xp=task.reward_xp,
            wallet_reference=wallet_ref,
        )

        # 5. Update Task and Attempt state
        task.total_completions = F('total_completions') + 1
        task.save(update_fields=['total_completions'])

        attempt.status = TaskAttemptStatus.COMPLETED
        attempt.completed_at = timezone.now()
        attempt.reward_granted = True
        attempt.reward_granted_at = timezone.now()
        attempt.reward_reference = wallet_ref
        attempt.save()

        logger.info("Granted %s coins for attempt %s (ref: %s)", task.reward_coins, attempt.id, wallet_ref)
        return grant

    @staticmethod
    def grant_xp(user, amount: int, reason: str = "", reference: str = ""):
        """
        Grant experience points (XP) to user profile.
        """
        if amount <= 0:
            return
        if hasattr(user, 'profile'):
            user.profile.xp = F('xp') + amount
            user.profile.save(update_fields=['xp'])


class TaskAttemptService:
    """
    Manages task attempt lifecycle and initiation.
    """
    @staticmethod
    def get_or_create_attempt(user, task: Task) -> tuple[TaskAttempt, bool]:
        """
        Retrieves an ongoing attempt or creates a new one after validating eligibility.
        """
        # Look for existing in-progress attempt
        existing = TaskAttempt.objects.filter(
            user=user,
            task=task,
            status__in=[
                TaskAttemptStatus.CREATED,
                TaskAttemptStatus.IN_PROGRESS,
                TaskAttemptStatus.AWAITING_QUIZ,
                TaskAttemptStatus.VERIFYING,
            ]
        ).first()

        if existing:
            return existing, False

        # Validate eligibility before creating new attempt
        eligibility = TaskEligibilityService.check(user, task)
        if not eligibility["eligible"]:
            raise ValidationError("; ".join(eligibility["reasons"]) or "User is not eligible for this task.")

        attempt = TaskAttempt.objects.create(
            user=user,
            task=task,
            status=TaskAttemptStatus.IN_PROGRESS,
            quiz_required=task.quiz_required,
        )
        return attempt, True

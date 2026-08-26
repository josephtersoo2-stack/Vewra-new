import uuid
from django.db import models
from django.conf import settings
from django.utils import timezone

class WatchSessionStatus(models.TextChoices):
    ACTIVE = "ACTIVE", "Active"
    PAUSED = "PAUSED", "Paused"
    COMPLETED = "COMPLETED", "Completed"
    INVALID = "INVALID", "Invalid"
    EXPIRED = "EXPIRED", "Expired"
    ABANDONED = "ABANDONED", "Abandoned"

class WatchEventType(models.TextChoices):
    SESSION_STARTED = "SESSION_STARTED", "Session Started"
    PLAY = "PLAY", "Play"
    PAUSE = "PAUSE", "Pause"
    HEARTBEAT = "HEARTBEAT", "Heartbeat"
    APP_BACKGROUND = "APP_BACKGROUND", "App Background"
    APP_FOREGROUND = "APP_FOREGROUND", "App Foreground"
    VISIBILITY_LOST = "VISIBILITY_LOST", "Visibility Lost"
    VISIBILITY_RESTORED = "VISIBILITY_RESTORED", "Visibility Restored"
    PLAYER_ENDED = "PLAYER_ENDED", "Player Ended"
    QUIZ_STARTED = "QUIZ_STARTED", "Quiz Started"
    QUIZ_SUBMITTED = "QUIZ_SUBMITTED", "Quiz Submitted"
    SESSION_COMPLETED = "SESSION_COMPLETED", "Session Completed"
    SESSION_INVALIDATED = "SESSION_INVALIDATED", "Session Invalidated"

class WatchSession(models.Model):
    """
    Tracks real-time authenticated watch progress and security state.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    attempt = models.OneToOneField('tasks.TaskAttempt', on_delete=models.CASCADE, related_name='watch_session')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='watch_sessions')
    task = models.ForeignKey('tasks.Task', on_delete=models.CASCADE, related_name='watch_sessions')

    session_token_hash = models.CharField(max_length=64, db_index=True)
    status = models.CharField(max_length=20, choices=WatchSessionStatus.choices, default=WatchSessionStatus.ACTIVE, db_index=True)

    started_at = models.DateTimeField(default=timezone.now)
    last_heartbeat_at = models.DateTimeField(null=True, blank=True)
    ended_at = models.DateTimeField(null=True, blank=True)

    required_seconds = models.PositiveIntegerField(default=60)
    credited_watch_seconds = models.PositiveIntegerField(default=0)
    heartbeat_count = models.PositiveIntegerField(default=0)
    invalid_event_count = models.PositiveIntegerField(default=0)

    client_platform = models.CharField(max_length=50, default="MOBILE")
    app_version = models.CharField(max_length=50, default="1.0.0")
    device_id_hash = models.CharField(max_length=64, blank=True)
    client_session_id = models.CharField(max_length=100, blank=True)

    last_sequence = models.PositiveIntegerField(default=0)
    last_client_position = models.FloatField(null=True, blank=True)
    is_backgrounded = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_watch_sessions'
        ordering = ['-started_at']
        indexes = [
            models.Index(fields=['user', 'status']),
            models.Index(fields=['session_token_hash']),
        ]

    def __str__(self):
        return f"WatchSession {self.id} [{self.status}] ({self.credited_watch_seconds}/{self.required_seconds}s)"

    @property
    def progress_percentage(self) -> float:
        if self.required_seconds <= 0:
            return 100.0
        return min(100.0, round((self.credited_watch_seconds / self.required_seconds) * 100.0, 2))

    @property
    def is_watch_satisfied(self) -> bool:
        return self.credited_watch_seconds >= self.required_seconds


class WatchEvent(models.Model):
    """
    Append-only audit log for video playback and app lifecycle events.
    """
    id = models.BigAutoField(primary_key=True)
    session = models.ForeignKey(WatchSession, on_delete=models.CASCADE, related_name='events')
    event_type = models.CharField(max_length=30, choices=WatchEventType.choices)
    sequence = models.PositiveIntegerField()

    client_timestamp = models.DateTimeField(null=True, blank=True)
    server_timestamp = models.DateTimeField(auto_now_add=True)
    playback_position = models.FloatField(null=True, blank=True)
    metadata = models.JSONField(default=dict, blank=True)

    class Meta:
        db_table = 'vewra_watch_events'
        ordering = ['server_timestamp', 'sequence']
        constraints = [
            models.UniqueConstraint(fields=['session', 'sequence'], name='unique_session_sequence')
        ]

    def __str__(self):
        return f"Event #{self.sequence} {self.event_type} on Session {self.session_id}"

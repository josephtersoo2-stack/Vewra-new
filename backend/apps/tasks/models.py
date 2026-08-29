import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings
from django.utils import timezone
from django.core.exceptions import ValidationError
from django.utils.text import slugify

class TaskType(models.TextChoices):
    VIDEO = "VIDEO", "Video"
    SURVEY = "SURVEY", "Survey"
    SOCIAL = "SOCIAL", "Social"
    CHALLENGE = "CHALLENGE", "Challenge"

class TaskStatus(models.TextChoices):
    DRAFT = "DRAFT", "Draft"
    ACTIVE = "ACTIVE", "Active"
    PAUSED = "PAUSED", "Paused"
    EXHAUSTED = "EXHAUSTED", "Exhausted"
    EXPIRED = "EXPIRED", "Expired"
    ARCHIVED = "ARCHIVED", "Archived"

class Task(models.Model):
    """
    Core Task entity defining earning campaigns, required watch time, eligibility rules, and rewards.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    task_type = models.CharField(max_length=20, choices=TaskType.choices, default=TaskType.VIDEO, db_index=True)
    status = models.CharField(max_length=20, choices=TaskStatus.choices, default=TaskStatus.ACTIVE, db_index=True)
    
    title = models.CharField(max_length=255)
    slug = models.SlugField(max_length=255, unique=True, blank=True)
    description = models.TextField(blank=True)
    instructions = models.JSONField(default=list, blank=True, help_text="List of string steps for the user")
    
    thumbnail_url = models.URLField(max_length=500, blank=True)
    source_url = models.URLField(max_length=500)
    source_platform = models.CharField(max_length=50, default="YouTube")
    channel_name = models.CharField(max_length=150, blank=True)
    video_id = models.CharField(max_length=30, blank=True, db_index=True)
    keywords = models.JSONField(default=list, blank=True)
    search_keywords = models.TextField(blank=True)

    REWARD_TYPE_CHOICES = [
        ('per_time', 'Per Time'),
        ('watch_all', 'Watch All'),
        ('target', 'Target'),
    ]
    reward_type = models.CharField(max_length=20, choices=REWARD_TYPE_CHOICES, default='target')
    reward_config = models.JSONField(default=dict, blank=True)

    reward_coins = models.PositiveBigIntegerField(default=10)
    reward_cash = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0.00'))
    reward_xp = models.PositiveIntegerField(default=25)

    required_watch_seconds = models.PositiveIntegerField(default=60)
    quiz_required = models.BooleanField(default=False)
    quiz_pass_percentage = models.PositiveIntegerField(default=70)

    daily_user_limit = models.PositiveIntegerField(default=1, help_text="Max completions per user per day")
    total_completion_limit = models.PositiveIntegerField(null=True, blank=True, help_text="Global campaign capacity")
    total_completions = models.PositiveIntegerField(default=0)

    minimum_level = models.PositiveIntegerField(default=1)
    minimum_trust_score = models.PositiveIntegerField(default=50)
    verification_required = models.BooleanField(default=False)

    starts_at = models.DateTimeField(null=True, blank=True, db_index=True)
    expires_at = models.DateTimeField(null=True, blank=True, db_index=True)

    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='created_tasks'
    )
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_tasks'
        ordering = ['-created_at']
        verbose_name = 'YouTube Video Task'
        verbose_name_plural = 'YouTube Video Tasks'
        indexes = [
            models.Index(fields=['status', 'task_type']),
            models.Index(fields=['starts_at', 'expires_at']),
        ]

    def __str__(self):
        return f"{self.title} ({self.task_type} - {self.reward_coins} Coins)"

    def clean(self):
        if self.task_type == TaskType.VIDEO and self.required_watch_seconds <= 0:
            raise ValidationError("Video tasks must require at least 1 second of watch time.")
        cash_val = Decimal(str(self.reward_cash)) if self.reward_cash is not None else Decimal('0.00')
        if self.reward_coins < 0 or cash_val < Decimal('0.00') or self.reward_xp < 0:
            raise ValidationError("Rewards cannot be negative.")
        if not (0 <= self.quiz_pass_percentage <= 100):
            raise ValidationError("Quiz pass percentage must be between 0 and 100.")
        if not (0 <= self.minimum_trust_score <= 100):
            raise ValidationError("Minimum trust score must be between 0 and 100.")
        if self.starts_at and self.expires_at and self.starts_at > self.expires_at:
            raise ValidationError("Start date cannot be after expiry date.")

    def save(self, *args, **kwargs):
        if not self.video_id and self.source_url:
            from .services import extract_youtube_video_id
            self.video_id = extract_youtube_video_id(self.source_url)

        # Auto-fetch title, channel_name, thumbnail, and keywords if all are missing
        if self.video_id and not self.title and not self.keywords:
            try:
                from .services import extract_youtube_metadata
                meta = extract_youtube_metadata(self.source_url or self.video_id)
                if not self.title and meta.get('title'):
                    self.title = meta['title']
                if not self.channel_name and meta.get('channel'):
                    self.channel_name = meta['channel']
                if not self.thumbnail_url and meta.get('thumbnail_url'):
                    self.thumbnail_url = meta['thumbnail_url']
                if not self.keywords and meta.get('keywords'):
                    self.keywords = meta['keywords']
            except Exception:
                pass

        if not self.thumbnail_url and self.video_id:
            self.thumbnail_url = f"https://img.youtube.com/vi/{self.video_id}/hqdefault.jpg"

        if isinstance(self.keywords, list) and self.keywords and not self.search_keywords:
            self.search_keywords = ", ".join(str(k) for k in self.keywords)

        # Synchronize required_watch_seconds and reward_config with selected reward_type
        if self.reward_type == 'per_time':
            if isinstance(self.reward_config, dict) and self.reward_config.get('interval_seconds'):
                self.required_watch_seconds = int(self.reward_config['interval_seconds'])
            elif self.required_watch_seconds > 0:
                if not isinstance(self.reward_config, dict):
                    self.reward_config = {}
                self.reward_config['interval_seconds'] = self.required_watch_seconds
                self.reward_config['coins_per_interval'] = self.reward_coins
        elif self.reward_type == 'target':
            if isinstance(self.reward_config, dict) and self.reward_config.get('target_seconds'):
                self.required_watch_seconds = int(self.reward_config['target_seconds'])
            elif self.required_watch_seconds > 0:
                if not isinstance(self.reward_config, dict):
                    self.reward_config = {}
                self.reward_config['target_seconds'] = self.required_watch_seconds
                self.reward_config['coins'] = self.reward_coins
        elif self.reward_type == 'watch_all':
            if isinstance(self.reward_config, dict) and self.reward_config.get('full_duration_seconds'):
                self.required_watch_seconds = int(self.reward_config['full_duration_seconds'])
            elif self.required_watch_seconds > 0:
                if not isinstance(self.reward_config, dict):
                    self.reward_config = {}
                self.reward_config['full_duration_seconds'] = self.required_watch_seconds
                self.reward_config['coins'] = self.reward_coins

        if not self.slug:
            base_slug = slugify(self.title or f"task-{uuid.uuid4().hex[:8]}") or f"task-{uuid.uuid4().hex[:8]}"
            slug = base_slug
            counter = 1
            while Task.objects.filter(slug=slug).exclude(pk=self.pk).exists():
                slug = f"{base_slug}-{counter}"
                counter += 1
            self.slug = slug
        self.clean()
        super().save(*args, **kwargs)

    @property
    def reward_summary(self) -> str:
        cfg = self.reward_config or {}
        if self.reward_type == 'per_time':
            coins = cfg.get('coins_per_interval', cfg.get('coins', self.reward_coins))
            seconds = cfg.get('interval_seconds', cfg.get('seconds', self.required_watch_seconds or 60))
            return f"+{coins} coins / {seconds}s"
        elif self.reward_type == 'watch_all':
            coins = cfg.get('coins', self.reward_coins)
            return f"+{coins} coins (Full Watch)"
        elif self.reward_type == 'target':
            coins = cfg.get('coins', self.reward_coins)
            target_sec = cfg.get('target_seconds', self.required_watch_seconds)
            return f"+{coins} coins for {target_sec}s"
        return f"+{self.reward_coins} coins"

    @property
    def duration_minutes(self) -> int:
        return max(1, (self.required_watch_seconds + 59) // 60)

    @property
    def is_available(self) -> bool:
        if self.status != TaskStatus.ACTIVE:
            return False
        now = timezone.now()
        if self.starts_at and now < self.starts_at:
            return False
        if self.expires_at and now > self.expires_at:
            return False
        if self.total_completion_limit and self.total_completions >= self.total_completion_limit:
            return False
        return True

    @property
    def is_active(self) -> bool:
        now = timezone.now()
        if self.status != TaskStatus.ACTIVE:
            return False
        if self.starts_at and now < self.starts_at:
            return False
        if self.expires_at and now > self.expires_at:
            return False
        if self.total_completion_limit and self.total_completions >= self.total_completion_limit:
            return False
        return True


class TaskAttemptStatus(models.TextChoices):
    CREATED = "CREATED", "Created"
    IN_PROGRESS = "IN_PROGRESS", "In Progress"
    AWAITING_QUIZ = "AWAITING_QUIZ", "Awaiting Quiz"
    VERIFYING = "VERIFYING", "Verifying"
    COMPLETED = "COMPLETED", "Completed"
    FAILED = "FAILED", "Failed"
    EXPIRED = "EXPIRED", "Expired"
    ABANDONED = "ABANDONED", "Abandoned"


class TaskAttempt(models.Model):
    """
    Represents an authenticated user's engagement attempt with a task.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='task_attempts')
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name='attempts')
    
    status = models.CharField(max_length=20, choices=TaskAttemptStatus.choices, default=TaskAttemptStatus.CREATED, db_index=True)
    
    started_at = models.DateTimeField(default=timezone.now)
    completed_at = models.DateTimeField(null=True, blank=True)
    failed_at = models.DateTimeField(null=True, blank=True)

    reward_granted = models.BooleanField(default=False)
    reward_granted_at = models.DateTimeField(null=True, blank=True)
    reward_reference = models.CharField(max_length=100, unique=True, null=True, blank=True)

    quiz_required = models.BooleanField(default=False)
    quiz_passed = models.BooleanField(null=True, blank=True)
    quiz_score = models.FloatField(null=True, blank=True)
    failure_reason = models.CharField(max_length=255, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_task_attempts'
        ordering = ['-started_at']
        verbose_name = 'Task Completion Attempt'
        verbose_name_plural = 'Task Completion Attempts'
        indexes = [
            models.Index(fields=['user', 'task', 'status']),
            models.Index(fields=['started_at']),
        ]

    def __str__(self):
        return f"Attempt {self.id} - {self.user.username} on '{self.task.title}' [{self.status}]"


class TaskRewardGrant(models.Model):
    """
    Immutable ledger of task reward grants ensuring idempotency.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='task_reward_grants')
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name='reward_grants')
    attempt = models.OneToOneField(TaskAttempt, on_delete=models.CASCADE, related_name='reward_grant')

    coins = models.PositiveBigIntegerField(default=0)
    cash = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0.00'))
    xp = models.PositiveIntegerField(default=0)

    wallet_reference = models.CharField(max_length=100, unique=True)
    granted_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'vewra_task_reward_grants'
        ordering = ['-granted_at']
        verbose_name = 'Task Reward Grant'
        verbose_name_plural = 'Task Reward Grants'

    def __str__(self):
        return f"RewardGrant for {self.user.username} ({self.coins} Coins, ref: {self.wallet_reference})"


class QuizQuestionType(models.TextChoices):
    MULTIPLE_CHOICE = "MULTIPLE_CHOICE", "Multiple Choice"


class QuizQuestion(models.Model):
    """
    Server-authoritative quiz questions for task completion verification.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name='quiz_questions')
    
    question_text = models.TextField()
    question_type = models.CharField(max_length=20, choices=QuizQuestionType.choices, default=QuizQuestionType.MULTIPLE_CHOICE)
    options = models.JSONField(default=list, help_text="List of answer options e.g. ['A', 'B', 'C', 'D']")
    correct_answer = models.CharField(max_length=255, help_text="Server-only correct answer string")
    explanation = models.TextField(blank=True)
    source_timestamp_seconds = models.PositiveIntegerField(null=True, blank=True, help_text="Video timestamp for reference")
    difficulty = models.CharField(max_length=20, default="MEDIUM")
    active = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_quiz_questions'
        ordering = ['created_at']
        verbose_name = 'Quiz Question'
        verbose_name_plural = 'Quiz Questions'

    def __str__(self):
        return f"Q for '{self.task.title}': {self.question_text[:50]}"


class QuizAttempt(models.Model):
    """
    Tracks a user's quiz attempt for a specific task attempt.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    task_attempt = models.OneToOneField(TaskAttempt, on_delete=models.CASCADE, related_name='quiz_attempt')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='quiz_attempts')
    
    started_at = models.DateTimeField(default=timezone.now)
    submitted_at = models.DateTimeField(null=True, blank=True)
    score = models.FloatField(default=0.0)
    pass_percentage = models.PositiveIntegerField(default=70)
    passed = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_quiz_attempts'
        ordering = ['-started_at']
        verbose_name = 'Quiz Verification Attempt'
        verbose_name_plural = 'Quiz Verification Attempts'

    def __str__(self):
        return f"QuizAttempt for {self.user.username} - Score: {self.score}% (Passed: {self.passed})"


class QuizAnswer(models.Model):
    """
    Individual answer recorded for a quiz question.
    """
    id = models.BigAutoField(primary_key=True)
    quiz_attempt = models.ForeignKey(QuizAttempt, on_delete=models.CASCADE, related_name='answers')
    question = models.ForeignKey(QuizQuestion, on_delete=models.CASCADE, related_name='user_answers')
    selected_answer = models.CharField(max_length=255)
    is_correct = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'vewra_quiz_answers'
        ordering = ['created_at']
        verbose_name = 'Quiz Answer'
        verbose_name_plural = 'Quiz Answers'

    def __str__(self):
        return f"Answer to {self.question_id}: {self.selected_answer} (Correct: {self.is_correct})"

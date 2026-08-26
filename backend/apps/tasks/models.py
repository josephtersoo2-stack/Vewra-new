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
    search_keywords = models.TextField(blank=True)

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
        indexes = [
            models.Index(fields=['status', 'task_type']),
            models.Index(fields=['starts_at', 'expires_at']),
        ]

    def __str__(self):
        return f"{self.title} ({self.task_type} - {self.reward_coins} Coins)"

    def clean(self):
        if self.task_type == TaskType.VIDEO and self.required_watch_seconds <= 0:
            raise ValidationError("Video tasks must require at least 1 second of watch time.")
        if self.reward_coins < 0 or self.reward_cash < Decimal('0.00') or self.reward_xp < 0:
            raise ValidationError("Rewards cannot be negative.")
        if not (0 <= self.quiz_pass_percentage <= 100):
            raise ValidationError("Quiz pass percentage must be between 0 and 100.")
        if not (0 <= self.minimum_trust_score <= 100):
            raise ValidationError("Minimum trust score must be between 0 and 100.")
        if self.starts_at and self.expires_at and self.starts_at > self.expires_at:
            raise ValidationError("Start date cannot be after expiry date.")

    def save(self, *args, **kwargs):
        if not self.slug:
            base_slug = slugify(self.title) or f"task-{uuid.uuid4().hex[:8]}"
            slug = base_slug
            counter = 1
            while Task.objects.filter(slug=slug).exclude(pk=self.pk).exists():
                slug = f"{base_slug}-{counter}"
                counter += 1
            self.slug = slug
        self.clean()
        super().save(*args, **kwargs)

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

    def __str__(self):
        return f"Answer to {self.question_id}: {self.selected_answer} (Correct: {self.is_correct})"

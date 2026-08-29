from rest_framework import serializers
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

class TaskListSerializer(serializers.ModelSerializer):
    """Compact serializer for task catalog/feed."""
    reward_summary = serializers.ReadOnlyField()

    class Meta:
        model = Task
        fields = [
            'id',
            'title',
            'slug',
            'task_type',
            'status',
            'thumbnail_url',
            'channel_name',
            'video_id',
            'keywords',
            'reward_type',
            'reward_config',
            'reward_summary',
            'reward_coins',
            'reward_cash',
            'reward_xp',
            'required_watch_seconds',
            'quiz_required',
            'minimum_level',
            'minimum_trust_score',
            'verification_required',
            'created_at',
        ]
        read_only_fields = fields


class TaskDetailSerializer(serializers.ModelSerializer):
    """Comprehensive serializer for task details screen."""
    reward_summary = serializers.ReadOnlyField()
    instruction = serializers.SerializerMethodField()

    class Meta:
        model = Task
        fields = [
            'id',
            'title',
            'slug',
            'task_type',
            'status',
            'description',
            'instructions',
            'thumbnail_url',
            'source_url',
            'source_platform',
            'channel_name',
            'video_id',
            'keywords',
            'search_keywords',
            'reward_type',
            'reward_config',
            'reward_summary',
            'instruction',
            'reward_coins',
            'reward_cash',
            'reward_xp',
            'required_watch_seconds',
            'quiz_required',
            'quiz_pass_percentage',
            'daily_user_limit',
            'total_completion_limit',
            'total_completions',
            'minimum_level',
            'minimum_trust_score',
            'verification_required',
            'starts_at',
            'expires_at',
            'created_at',
        ]
        read_only_fields = fields

    def get_instruction(self, obj):
        from .services import generate_randomized_instruction
        request = self.context.get('request')
        user = request.user if request and request.user.is_authenticated else None
        return generate_randomized_instruction(obj, user)


class TaskEligibilityRequirementsSerializer(serializers.Serializer):
    account_active = serializers.BooleanField()
    task_active = serializers.BooleanField()
    schedule = serializers.BooleanField()
    capacity = serializers.BooleanField()
    level = serializers.BooleanField()
    trust_score = serializers.BooleanField()
    verification = serializers.BooleanField()
    daily_limit = serializers.BooleanField()
    repeat_rule = serializers.BooleanField()


class TaskEligibilitySerializer(serializers.Serializer):
    eligible = serializers.BooleanField()
    reasons = serializers.ListField(child=serializers.CharField())
    requirements = TaskEligibilityRequirementsSerializer()
    active_attempt_id = serializers.CharField(allow_null=True, required=False)


class TaskAttemptSerializer(serializers.ModelSerializer):
    task_id = serializers.UUIDField(source='task.id', read_only=True)
    task_title = serializers.CharField(source='task.title', read_only=True)
    task_thumbnail = serializers.URLField(source='task.thumbnail_url', read_only=True)
    reward_coins = serializers.IntegerField(source='task.reward_coins', read_only=True)

    class Meta:
        model = TaskAttempt
        fields = [
            'id',
            'task_id',
            'task_title',
            'task_thumbnail',
            'reward_coins',
            'status',
            'started_at',
            'completed_at',
            'reward_granted',
            'reward_reference',
            'quiz_required',
            'quiz_passed',
            'quiz_score',
            'failure_reason',
            'created_at',
        ]
        read_only_fields = fields


class QuizQuestionPublicSerializer(serializers.ModelSerializer):
    """
    Public serializer for quiz questions — NEVER exposes the correct answer.
    """
    class Meta:
        model = QuizQuestion
        fields = [
            'id',
            'question_text',
            'question_type',
            'options',
            'source_timestamp_seconds',
            'difficulty',
        ]
        read_only_fields = fields


class QuizAnswerItemSerializer(serializers.Serializer):
    question_id = serializers.UUIDField()
    selected_answer = serializers.CharField(max_length=255)


class QuizSubmissionSerializer(serializers.Serializer):
    answers = serializers.ListField(
        child=QuizAnswerItemSerializer(),
        allow_empty=False,
    )


class QuizResultSerializer(serializers.Serializer):
    attempt_id = serializers.UUIDField()
    score = serializers.FloatField()
    pass_percentage = serializers.IntegerField()
    passed = serializers.BooleanField()
    total_questions = serializers.IntegerField()
    correct_answers = serializers.IntegerField()

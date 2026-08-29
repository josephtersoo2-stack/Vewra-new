from decimal import Decimal
from django.contrib.auth import get_user_model
from rest_framework import serializers

from apps.tasks.models import Task, TaskAttempt, TaskRewardGrant
from apps.tracking.models import WatchSession, WatchEvent
from apps.wallet.models import Wallet, CoinTransaction, CashTransaction
from apps.ai.models import AIProviderConfig

User = get_user_model()


class AdminUserSerializer(serializers.ModelSerializer):
    coins = serializers.SerializerMethodField()
    cash = serializers.SerializerMethodField()
    level = serializers.SerializerMethodField()
    trust_score = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id',
            'email',
            'username',
            'country',
            'phone_number',
            'is_active',
            'is_staff',
            'is_superuser',
            'coins',
            'cash',
            'level',
            'trust_score',
            'is_verified',
            'created_at',
            'last_login',
        ]
        read_only_fields = ['id', 'created_at', 'last_login']

    def get_coins(self, obj) -> int:
        wallet = getattr(obj, 'wallet', None)
        return wallet.coin_balance if wallet else 0

    def get_cash(self, obj) -> str:
        wallet = getattr(obj, 'wallet', None)
        return str(wallet.cash_balance) if wallet else '0.00'

    def get_level(self, obj) -> int:
        profile = getattr(obj, 'profile', None)
        return getattr(profile, 'level', 1) if profile else 1

    def get_trust_score(self, obj) -> int:
        profile = getattr(obj, 'profile', None)
        return getattr(profile, 'trust_score', 50) if profile else 50


class AdminUserBalanceAdjustmentSerializer(serializers.Serializer):
    currency_type = serializers.ChoiceField(choices=['COINS', 'CASH'])
    adjustment_type = serializers.ChoiceField(choices=['CREDIT', 'DEBIT'])
    amount = serializers.DecimalField(max_digits=12, decimal_places=2, min_value=Decimal('0.01'))
    reason = serializers.CharField(max_length=255, required=True)


from apps.tasks.models import Task, TaskAttempt, TaskRewardGrant, QuizQuestion

class AdminQuizQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = QuizQuestion
        fields = [
            'id',
            'question_text',
            'question_type',
            'options',
            'correct_answer',
            'explanation',
            'source_timestamp_seconds',
            'difficulty',
            'active',
        ]
        read_only_fields = ['id']


class AdminVideoTaskSerializer(serializers.ModelSerializer):
    saved_keywords_count = serializers.SerializerMethodField()
    watch_sessions_count = serializers.SerializerMethodField()
    sessions_count = serializers.SerializerMethodField()
    total_watch_seconds = serializers.SerializerMethodField()
    live_viewers_count = serializers.SerializerMethodField()
    is_active = serializers.SerializerMethodField()
    quiz_questions = AdminQuizQuestionSerializer(many=True, required=False)
    created_by_email = serializers.EmailField(source='created_by.email', read_only=True)

    class Meta:
        model = Task
        fields = [
            'id',
            'title',
            'slug',
            'description',
            'instructions',
            'source_url',
            'source_platform',
            'channel_name',
            'video_id',
            'thumbnail_url',
            'task_type',
            'status',
            'is_active',
            'reward_type',
            'reward_config',
            'reward_coins',
            'reward_cash',
            'reward_xp',
            'required_watch_seconds',
            'quiz_required',
            'quiz_pass_percentage',
            'quiz_questions',
            'keywords',
            'search_keywords',
            'daily_user_limit',
            'total_completion_limit',
            'total_completions',
            'minimum_level',
            'minimum_trust_score',
            'verification_required',
            'saved_keywords_count',
            'watch_sessions_count',
            'sessions_count',
            'total_watch_seconds',
            'live_viewers_count',
            'starts_at',
            'expires_at',
            'created_by',
            'created_by_email',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'slug', 'created_at', 'updated_at']

    def get_saved_keywords_count(self, obj) -> int:
        return len(obj.keywords) if isinstance(obj.keywords, list) else 0

    def get_watch_sessions_count(self, obj) -> int:
        return WatchSession.objects.filter(task=obj).count()

    def get_sessions_count(self, obj) -> int:
        return WatchSession.objects.filter(task=obj).count()

    def get_total_watch_seconds(self, obj) -> int:
        from django.db.models import Sum
        return WatchSession.objects.filter(task=obj).aggregate(total=Sum('credited_watch_seconds'))['total'] or 0

    def get_live_viewers_count(self, obj) -> int:
        from datetime import timedelta
        from django.utils import timezone
        threshold = timezone.now() - timedelta(seconds=45)
        return WatchSession.objects.filter(task=obj, status='ACTIVE', last_heartbeat_at__gte=threshold).count()

    def get_is_active(self, obj) -> bool:
        return obj.status == 'ACTIVE'

    def create(self, validated_data):
        quiz_questions_data = validated_data.pop('quiz_questions', [])
        task = super().create(validated_data)
        for q_data in quiz_questions_data:
            QuizQuestion.objects.create(task=task, **q_data)
        return task

    def update(self, instance, validated_data):
        quiz_questions_data = validated_data.pop('quiz_questions', None)
        task = super().update(instance, validated_data)
        if quiz_questions_data is not None:
            # Update questions: keep existing if matches, create new
            instance.quiz_questions.all().delete()
            for q_data in quiz_questions_data:
                QuizQuestion.objects.create(task=task, **q_data)
        return task


class AdminWatchSessionSerializer(serializers.ModelSerializer):
    user_email = serializers.EmailField(source='user.email', read_only=True)
    user_name = serializers.CharField(source='user.username', read_only=True)
    task_title = serializers.CharField(source='task.title', read_only=True)
    task_video_id = serializers.CharField(source='task.video_id', read_only=True)
    progress_percentage = serializers.FloatField(read_only=True)

    class Meta:
        model = WatchSession
        fields = [
            'id',
            'attempt_id',
            'user_id',
            'user_email',
            'user_name',
            'task_id',
            'task_title',
            'task_video_id',
            'status',
            'required_seconds',
            'credited_watch_seconds',
            'progress_percentage',
            'heartbeat_count',
            'last_sequence',
            'last_client_position',
            'is_backgrounded',
            'started_at',
            'last_heartbeat_at',
            'ended_at',
        ]
        read_only_fields = fields


class AdminCoinTransactionSerializer(serializers.ModelSerializer):
    user_email = serializers.EmailField(source='user.email', read_only=True)
    user_name = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = CoinTransaction
        fields = [
            'id',
            'user_id',
            'user_email',
            'user_name',
            'transaction_type',
            'amount',
            'balance_after',
            'reference',
            'description',
            'created_at',
        ]
        read_only_fields = fields


class AdminAIProviderConfigSerializer(serializers.ModelSerializer):
    class Meta:
        model = AIProviderConfig
        fields = [
            'id',
            'provider_name',
            'api_key',
            'base_url',
            'youtube_keyword_model',
            'quiz_generation_model',
            'fraud_analysis_model',
            'is_active',
            'site_url',
            'site_name',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class AdminTestPromptSerializer(serializers.Serializer):
    provider = serializers.ChoiceField(choices=['OPENROUTER', 'GEMINI'], default='OPENROUTER')
    model = serializers.CharField(required=False, default='')
    prompt = serializers.CharField(required=False, default='')
    youtube_url = serializers.URLField(required=False, default='')

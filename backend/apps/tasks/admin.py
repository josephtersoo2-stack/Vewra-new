from django.contrib import admin
from .models import (
    Task,
    TaskAttempt,
    TaskRewardGrant,
    QuizQuestion,
    QuizAttempt,
    QuizAnswer,
)

class QuizQuestionInline(admin.StackedInline):
    model = QuizQuestion
    extra = 0
    fields = ('question_text', 'question_type', 'options', 'correct_answer', 'source_timestamp_seconds', 'difficulty', 'active')


@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):
    list_display = (
        'title',
        'task_type',
        'status',
        'reward_coins',
        'reward_cash',
        'reward_xp',
        'required_watch_seconds',
        'quiz_required',
        'total_completions',
        'created_at',
    )
    list_filter = ('task_type', 'status', 'quiz_required', 'verification_required')
    search_fields = ('title', 'slug', 'description', 'channel_name', 'search_keywords')
    prepopulated_fields = {'slug': ('title',)}
    inlines = [QuizQuestionInline]
    fieldsets = (
        ('Basic Information', {
            'fields': ('title', 'slug', 'task_type', 'status', 'description', 'instructions')
        }),
        ('Media Source', {
            'fields': ('source_url', 'source_platform', 'thumbnail_url', 'channel_name', 'search_keywords')
        }),
        ('Rewards', {
            'fields': ('reward_coins', 'reward_cash', 'reward_xp')
        }),
        ('Watch & Quiz Requirements', {
            'fields': ('required_watch_seconds', 'quiz_required', 'quiz_pass_percentage')
        }),
        ('Eligibility & Limits', {
            'fields': ('daily_user_limit', 'total_completion_limit', 'total_completions', 'minimum_level', 'minimum_trust_score', 'verification_required')
        }),
        ('Scheduling & Metadata', {
            'fields': ('starts_at', 'expires_at', 'created_by')
        }),
    )


@admin.register(TaskAttempt)
class TaskAttemptAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'user',
        'task',
        'status',
        'reward_granted',
        'quiz_passed',
        'started_at',
        'completed_at',
    )
    list_filter = ('status', 'reward_granted', 'quiz_passed')
    search_fields = ('id', 'user__username', 'user__email', 'task__title', 'reward_reference')
    readonly_fields = ('id', 'created_at', 'updated_at', 'reward_granted_at', 'reward_reference')


@admin.register(TaskRewardGrant)
class TaskRewardGrantAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'task', 'coins', 'cash', 'xp', 'wallet_reference', 'granted_at')
    search_fields = ('id', 'user__username', 'task__title', 'wallet_reference')
    readonly_fields = ('id', 'user', 'task', 'attempt', 'coins', 'cash', 'xp', 'wallet_reference', 'granted_at')


@admin.register(QuizQuestion)
class QuizQuestionAdmin(admin.ModelAdmin):
    list_display = ('id', 'task', 'question_text', 'question_type', 'difficulty', 'active', 'created_at')
    list_filter = ('difficulty', 'active', 'question_type')
    search_fields = ('question_text', 'task__title')


@admin.register(QuizAttempt)
class QuizAttemptAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'task_attempt', 'score', 'pass_percentage', 'passed', 'submitted_at')
    list_filter = ('passed',)
    search_fields = ('id', 'user__username', 'task_attempt__id')
    readonly_fields = ('id', 'created_at', 'updated_at')


@admin.register(QuizAnswer)
class QuizAnswerAdmin(admin.ModelAdmin):
    list_display = ('id', 'quiz_attempt', 'question', 'selected_answer', 'is_correct', 'created_at')
    list_filter = ('is_correct',)
    search_fields = ('quiz_attempt__id', 'question__question_text', 'selected_answer')
    readonly_fields = ('created_at',)

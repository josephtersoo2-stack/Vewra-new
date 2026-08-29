from django.contrib import admin
from django.utils.html import format_html
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
        'thumbnail_preview',
        'title',
        'video_id',
        'channel_name',
        'reward_type',
        'saved_keywords_count',
        'reward_summary',
        'status',
        'created_at',
    )
    list_filter = ('task_type', 'status', 'reward_type', 'quiz_required', 'verification_required')
    search_fields = ('title', 'slug', 'video_id', 'channel_name', 'search_keywords')
    readonly_fields = ('thumbnail_preview', 'video_id', 'saved_keywords_display', 'reward_summary', 'created_at', 'updated_at')
    inlines = [QuizQuestionInline]
    actions = ['delete_selected', 'generate_ai_keywords_action']

    def has_delete_permission(self, request, obj=None):
        return True

    fieldsets = (
        ('YouTube Video Task Upload & Configuration', {
            'fields': ('source_url', 'video_id', 'title', 'channel_name', 'thumbnail_url', 'task_type', 'status', 'description'),
            'description': 'Paste a YouTube video URL or ID. The system will automatically fetch the HD thumbnail, title, channel name, and use OpenRouter AI to extract transcript and generate 8 top-ranking search keywords.'
        }),
        ('AI & Search Keywords Pool', {
            'fields': ('saved_keywords_display', 'keywords', 'search_keywords'),
            'description': '8 Verified search keywords generated to guarantee top 2-5 ranking on YouTube search.'
        }),
        ('Reward Configuration', {
            'fields': ('reward_type', 'reward_config', 'reward_coins', 'reward_cash', 'reward_xp', 'required_watch_seconds')
        }),
        ('Watch & Quiz Verification', {
            'fields': ('quiz_required', 'quiz_pass_percentage')
        }),
        ('Eligibility & Campaign Limits', {
            'fields': ('daily_user_limit', 'total_completion_limit', 'total_completions', 'minimum_level', 'minimum_trust_score', 'verification_required')
        }),
        ('Scheduling & Metadata', {
            'fields': ('starts_at', 'expires_at', 'created_by', 'created_at', 'updated_at')
        }),
    )

    @admin.display(description="Preview")
    def thumbnail_preview(self, obj):
        url = obj.thumbnail_url
        if not url and obj.video_id:
            url = f"https://i.ytimg.com/vi/{obj.video_id}/hqdefault.jpg"
        if url:
            return format_html('<img src="{}" style="width: 72px; height: 42px; object-fit: cover; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);" />', url)
        return format_html('<span style="color: #999;">No image</span>')

    @admin.display(description="Saved Keywords")
    def saved_keywords_count(self, obj):
        kw = obj.keywords if isinstance(obj.keywords, list) else []
        if not kw:
            return format_html('<span style="color: #999;">No keywords</span>')
        first = kw[0] if len(kw) > 0 else ""
        return format_html('<strong>{} phrases</strong><br><small style="color: #666;">"{}"</small>', len(kw), first[:30])

    @admin.display(description="Formatted Keywords Pool")
    def saved_keywords_display(self, obj):
        kw = obj.keywords if isinstance(obj.keywords, list) else []
        if not kw:
            return format_html('<p style="color: #888;">No saved keywords. Save this task or run "Generate AI Keywords" action to populate.</p>')
        
        items_html = "".join([
            f'<li style="margin-bottom: 6px; padding: 4px 8px; background: #f0f4ff; border-radius: 4px; display: inline-block; margin-right: 8px;">'
            f'<span style="font-weight: bold; color: #3b82f6;">#{i+1}</span> <code style="font-size: 13px; color: #1e293b;">{k}</code>'
            f'</li>'
            for i, k in enumerate(kw)
        ])
        return format_html(
            '<div style="max-height: 240px; overflow-y: auto; padding: 10px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px;">'
            '<p style="margin-top: 0; font-size: 12px; color: #64748b;"><strong>Total: {} verified phrases</strong> (rotates randomly among users):</p>'
            '<ul style="list-style: none; padding-left: 0; margin-bottom: 0;">{}</ul>'
            '</div>',
            len(kw),
            format_html(items_html)
        )

    @admin.action(description="⚡ Extract Transcript & Generate 8 SEO Keywords with OpenRouter")
    def generate_ai_keywords_action(self, request, queryset):
        from .services import extract_youtube_metadata
        updated = 0
        for task in queryset:
            try:
                meta = extract_youtube_metadata(task.source_url or task.video_id)
                task.title = meta.get('title', task.title)
                task.channel_name = meta.get('channel', task.channel_name)
                task.thumbnail_url = meta.get('thumbnail_url', task.thumbnail_url)
                task.keywords = meta.get('keywords', task.keywords)
                task.save()
                updated += 1
            except Exception as e:
                self.message_user(request, f"Error updating task {task.id}: {e}", level='ERROR')
        self.message_user(request, f"Successfully refreshed YouTube metadata and 8 SEO keywords for {updated} task(s).")


@admin.register(TaskAttempt)
class TaskAttemptAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'user',
        'task',
        'status',
        'reward_granted',
        'quiz_required',
        'quiz_passed',
        'quiz_score',
        'started_at',
        'completed_at',
    )
    list_filter = ('status', 'reward_granted', 'quiz_required', 'quiz_passed')
    search_fields = ('user__username', 'user__email', 'task__title', 'failure_reason')
    readonly_fields = ('started_at', 'completed_at', 'created_at', 'updated_at')
    actions = ['delete_selected']

    def has_delete_permission(self, request, obj=None):
        return True


@admin.register(TaskRewardGrant)
class TaskRewardGrantAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'task', 'attempt', 'coins', 'cash', 'xp', 'wallet_reference', 'granted_at')
    list_filter = ('granted_at',)
    search_fields = ('user__username', 'user__email', 'task__title', 'wallet_reference')
    readonly_fields = ('granted_at',)
    actions = ['delete_selected']

    def has_delete_permission(self, request, obj=None):
        return True


@admin.register(QuizAttempt)
class QuizAttemptAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'task_attempt', 'score', 'pass_percentage', 'passed', 'submitted_at')
    list_filter = ('passed', 'created_at', 'submitted_at')
    search_fields = ('user__username', 'task_attempt__task__title')
    readonly_fields = ('started_at', 'submitted_at', 'created_at', 'updated_at')
    actions = ['delete_selected']

    def has_delete_permission(self, request, obj=None):
        return True


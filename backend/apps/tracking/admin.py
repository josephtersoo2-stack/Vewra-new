from django.contrib import admin
from .models import WatchSession, WatchEvent

class WatchEventInline(admin.TabularInline):
    model = WatchEvent
    extra = 0
    readonly_fields = ('sequence', 'event_type', 'client_timestamp', 'server_timestamp', 'playback_position', 'metadata')
    can_delete = False

    def has_add_permission(self, request, obj=None):
        return False


@admin.register(WatchSession)
class WatchSessionAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'user',
        'task',
        'status',
        'credited_watch_seconds',
        'required_seconds',
        'heartbeat_count',
        'invalid_event_count',
        'is_backgrounded',
        'started_at',
    )
    list_filter = ('status', 'client_platform', 'is_backgrounded')
    search_fields = ('id', 'user__username', 'task__title', 'session_token_hash')
    readonly_fields = (
        'id',
        'session_token_hash',
        'created_at',
        'updated_at',
        'started_at',
        'ended_at',
        'last_heartbeat_at',
    )
    inlines = [WatchEventInline]


@admin.register(WatchEvent)
class WatchEventAdmin(admin.ModelAdmin):
    list_display = ('id', 'session', 'event_type', 'sequence', 'server_timestamp', 'playback_position')
    list_filter = ('event_type',)
    search_fields = ('session__id', 'event_type')
    readonly_fields = ('id', 'session', 'event_type', 'sequence', 'client_timestamp', 'server_timestamp', 'playback_position', 'metadata')

    def has_add_permission(self, request):
        return False

    def has_delete_permission(self, request, obj=None):
        return False

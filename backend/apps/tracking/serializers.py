from rest_framework import serializers
from .models import WatchSession, WatchEvent, WatchEventType

class WatchSessionSerializer(serializers.ModelSerializer):
    attempt_id = serializers.UUIDField(source='attempt.id', read_only=True)
    task_id = serializers.UUIDField(source='task.id', read_only=True)
    progress_percentage = serializers.FloatField(read_only=True)
    is_satisfied = serializers.BooleanField(source='is_watch_satisfied', read_only=True)
    source_url = serializers.URLField(source='task.source_url', read_only=True)
    channel_name = serializers.CharField(source='task.channel_name', read_only=True)

    class Meta:
        model = WatchSession
        fields = [
            'id',
            'attempt_id',
            'task_id',
            'status',
            'required_seconds',
            'credited_watch_seconds',
            'progress_percentage',
            'is_satisfied',
            'source_url',
            'channel_name',
            'last_sequence',
            'heartbeat_count',
            'created_at',
        ]
        read_only_fields = fields


class WatchHeartbeatSerializer(serializers.Serializer):
    sequence = serializers.IntegerField(min_value=1)
    playback_position = serializers.FloatField(required=False, allow_null=True)
    client_timestamp = serializers.DateTimeField(required=False, allow_null=True)


class WatchEventInputSerializer(serializers.Serializer):
    event_type = serializers.ChoiceField(choices=[
        WatchEventType.PLAY,
        WatchEventType.PAUSE,
        WatchEventType.APP_BACKGROUND,
        WatchEventType.APP_FOREGROUND,
        WatchEventType.PLAYER_ENDED,
        WatchEventType.VISIBILITY_LOST,
        WatchEventType.VISIBILITY_RESTORED,
    ])
    sequence = serializers.IntegerField(min_value=1)
    playback_position = serializers.FloatField(required=False, allow_null=True)
    metadata = serializers.DictField(required=False, default=dict)

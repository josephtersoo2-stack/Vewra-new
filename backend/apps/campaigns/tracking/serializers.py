from rest_framework import serializers
from apps.campaigns.tracking.models import (
    ClickType,
    AdvertisementImpression,
    AdvertisementClick,
    AdvertisementVideoEngagement,
)


class ImpressionRecordSerializer(serializers.Serializer):
    """
    Serializer for recording incoming advertisement impressions.
    """
    campaign_id = serializers.UUIDField(required=True)
    placement_id = serializers.UUIDField(required=True)
    media_id = serializers.UUIDField(required=True)
    session_id = serializers.CharField(required=False, allow_blank=True, default="")
    device_id = serializers.CharField(required=False, allow_null=True, allow_blank=True, default=None)


class ClickRecordSerializer(serializers.Serializer):
    """
    Serializer for recording advertisement clicks and interactions.
    """
    campaign_id = serializers.UUIDField(required=True)
    media_id = serializers.UUIDField(required=True)
    impression_id = serializers.UUIDField(required=False, allow_null=True, default=None)
    click_type = serializers.ChoiceField(choices=ClickType.choices, default=ClickType.BANNER_CLICK)
    session_id = serializers.CharField(required=False, allow_blank=True, default="")


class VideoProgressRecordSerializer(serializers.Serializer):
    """
    Serializer for reporting video advertisement playback progress.
    """
    campaign_id = serializers.UUIDField(required=True)
    media_id = serializers.UUIDField(required=True)
    session_id = serializers.CharField(required=True)
    watched_seconds = serializers.FloatField(required=True, min_value=0.0)


class AdvertisementImpressionSerializer(serializers.ModelSerializer):
    campaign_title = serializers.CharField(source="campaign.title", read_only=True)
    media_title = serializers.CharField(source="media.title", read_only=True)

    class Meta:
        model = AdvertisementImpression
        fields = [
            "id",
            "campaign",
            "campaign_title",
            "placement",
            "media",
            "media_title",
            "user",
            "session_id",
            "device_id",
            "created_at",
        ]
        read_only_fields = fields


class AdvertisementClickSerializer(serializers.ModelSerializer):
    campaign_title = serializers.CharField(source="campaign.title", read_only=True)
    media_title = serializers.CharField(source="media.title", read_only=True)
    click_type_display = serializers.CharField(source="get_click_type_display", read_only=True)

    class Meta:
        model = AdvertisementClick
        fields = [
            "id",
            "impression",
            "campaign",
            "campaign_title",
            "media",
            "media_title",
            "user",
            "click_type",
            "click_type_display",
            "session_id",
            "created_at",
        ]
        read_only_fields = fields


class AdvertisementVideoEngagementSerializer(serializers.ModelSerializer):
    media_title = serializers.CharField(source="media.title", read_only=True)

    class Meta:
        model = AdvertisementVideoEngagement
        fields = [
            "id",
            "campaign",
            "media",
            "media_title",
            "user",
            "session_id",
            "watched_seconds",
            "completion_percentage",
            "completed",
            "created_at",
            "updated_at",
        ]
        read_only_fields = fields

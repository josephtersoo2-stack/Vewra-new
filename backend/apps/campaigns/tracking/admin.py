from django.contrib import admin
from apps.campaigns.tracking.models import (
    AdvertisementImpression,
    AdvertisementClick,
    AdvertisementVideoEngagement,
)


@admin.register(AdvertisementImpression)
class AdvertisementImpressionAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "campaign",
        "placement",
        "media",
        "user",
        "session_id",
        "created_at",
    )
    list_filter = (
        "placement__placement_type",
        "campaign",
        "created_at",
    )
    search_fields = (
        "session_id",
        "device_id",
        "campaign__title",
        "user__email",
        "user__username",
    )
    readonly_fields = (
        "id",
        "campaign",
        "placement",
        "media",
        "user",
        "session_id",
        "device_id",
        "ip_hash",
        "user_agent",
        "created_at",
    )
    date_hierarchy = "created_at"


@admin.register(AdvertisementClick)
class AdvertisementClickAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "campaign",
        "media",
        "click_type",
        "user",
        "session_id",
        "created_at",
    )
    list_filter = (
        "click_type",
        "campaign",
        "created_at",
    )
    search_fields = (
        "session_id",
        "campaign__title",
        "media__title",
        "user__email",
        "user__username",
    )
    readonly_fields = (
        "id",
        "impression",
        "campaign",
        "media",
        "user",
        "click_type",
        "session_id",
        "created_at",
    )
    date_hierarchy = "created_at"


@admin.register(AdvertisementVideoEngagement)
class AdvertisementVideoEngagementAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "campaign",
        "media",
        "watched_seconds",
        "completion_percentage",
        "completed",
        "user",
        "updated_at",
    )
    list_filter = (
        "completed",
        "campaign",
        "updated_at",
    )
    search_fields = (
        "session_id",
        "campaign__title",
        "media__title",
        "user__email",
        "user__username",
    )
    readonly_fields = (
        "id",
        "campaign",
        "media",
        "user",
        "session_id",
        "watched_seconds",
        "completion_percentage",
        "completed",
        "created_at",
        "updated_at",
    )
    date_hierarchy = "updated_at"

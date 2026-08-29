from django.contrib import admin
from .models import Campaign


@admin.register(Campaign)
class CampaignAdmin(admin.ModelAdmin):
    list_display = (
        "title",
        "campaign_type",
        "status",
        "owner",
        "budget",
        "start_date",
        "end_date",
        "created_at",
    )
    list_filter = (
        "status",
        "campaign_type",
        "created_at",
    )
    search_fields = (
        "title",
        "description",
        "owner__email",
        "owner__username",
    )
    readonly_fields = (
        "id",
        "created_at",
        "updated_at",
    )
    ordering = ("-created_at",)
    list_per_page = 25
    fieldsets = (
        ("Core Information", {
            "fields": ("id", "title", "campaign_type", "status", "owner")
        }),
        ("Details & Budget", {
            "fields": ("description", "budget", "start_date", "end_date")
        }),
        ("Timestamps", {
            "fields": ("created_at", "updated_at"),
            "classes": ("collapse",)
        }),
    )

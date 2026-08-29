from django.contrib import admin
from django.utils.html import format_html
from .models import Campaign, CampaignMedia, MediaStatus


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


@admin.register(CampaignMedia)
class CampaignMediaAdmin(admin.ModelAdmin):
    list_display = (
        "title",
        "media_type",
        "status",
        "campaign",
        "uploaded_by",
        "formatted_size",
        "mime_type",
        "created_at",
    )
    list_filter = (
        "status",
        "media_type",
        "created_at",
    )
    search_fields = (
        "title",
        "description",
        "campaign__title",
        "uploaded_by__email",
        "uploaded_by__username",
    )
    readonly_fields = (
        "id",
        "file_size",
        "mime_type",
        "width",
        "height",
        "duration_seconds",
        "created_at",
        "updated_at",
    )
    ordering = ("-created_at",)
    list_per_page = 25
    actions = ["disable_selected_media", "restore_selected_media"]

    fieldsets = (
        ("Media Asset", {
            "fields": ("id", "title", "campaign", "media_type", "status", "uploaded_by")
        }),
        ("File & Creative", {
            "fields": ("file", "thumbnail", "description")
        }),
        ("Technical Specifications", {
            "fields": ("file_size", "mime_type", "width", "height", "duration_seconds")
        }),
        ("Timestamps", {
            "fields": ("created_at", "updated_at"),
            "classes": ("collapse",)
        }),
    )

    def formatted_size(self, obj):
        size = obj.file_size
        if size < 1024:
            return f"{size} B"
        elif size < 1024 * 1024:
            return f"{size / 1024:.1f} KB"
        return f"{size / (1024 * 1024):.2f} MB"
    formatted_size.short_description = "Size"

    @admin.action(description="Disable selected media assets")
    def disable_selected_media(self, request, queryset):
        count = queryset.update(status=MediaStatus.DISABLED)
        self.message_user(request, f"Successfully disabled {count} media assets.")

    @admin.action(description="Restore selected media assets to READY")
    def restore_selected_media(self, request, queryset):
        count = queryset.update(status=MediaStatus.READY)
        self.message_user(request, f"Successfully restored {count} media assets to READY.")

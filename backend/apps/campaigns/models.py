import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings


class CampaignType(models.TextChoices):
    TASK = "TASK", "Task Campaign"
    ADVERTISEMENT = "ADVERTISEMENT", "Advertisement Campaign"
    SPONSORED_CONTENT = "SPONSORED_CONTENT", "Sponsored Content Campaign"


class CampaignStatus(models.TextChoices):
    DRAFT = "DRAFT", "Draft"
    PENDING_REVIEW = "PENDING_REVIEW", "Pending Review"
    ACTIVE = "ACTIVE", "Active"
    PAUSED = "PAUSED", "Paused"
    COMPLETED = "COMPLETED", "Completed"
    REJECTED = "REJECTED", "Rejected"


class Campaign(models.Model):
    """
    Core Campaign entity serving as parent for Task Campaigns,
    Advertisement Campaigns, and Sponsored Content Campaigns.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="campaigns",
        db_index=True,
    )
    campaign_type = models.CharField(
        max_length=30,
        choices=CampaignType.choices,
        default=CampaignType.TASK,
        db_index=True,
    )
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True, default="")
    status = models.CharField(
        max_length=30,
        choices=CampaignStatus.choices,
        default=CampaignStatus.DRAFT,
        db_index=True,
    )
    budget = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=Decimal("0.00"),
    )
    start_date = models.DateTimeField(null=True, blank=True)
    end_date = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        verbose_name = "Campaign"
        verbose_name_plural = "Campaigns"
        indexes = [
            models.Index(fields=["status"], name="idx_campaign_status"),
            models.Index(fields=["campaign_type"], name="idx_campaign_type"),
            models.Index(fields=["owner", "status"], name="idx_campaign_owner_status"),
            models.Index(fields=["status", "campaign_type"], name="idx_campaign_status_type"),
        ]

    def __str__(self):
        return f"{self.title} ({self.get_campaign_type_display()}) - {self.get_status_display()}"


class MediaType(models.TextChoices):
    VIDEO = "VIDEO", "Video Asset"
    IMAGE = "IMAGE", "Image Asset"
    BANNER = "BANNER", "Banner Asset"


class MediaStatus(models.TextChoices):
    DRAFT = "DRAFT", "Draft"
    PROCESSING = "PROCESSING", "Processing"
    READY = "READY", "Ready"
    FAILED = "FAILED", "Failed"
    DISABLED = "DISABLED", "Disabled"


class CampaignMedia(models.Model):
    """
    Media Asset model storing verified creatives (videos, images, banners)
    attached to campaigns for advertising and promotional delivery.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    campaign = models.ForeignKey(
        Campaign,
        on_delete=models.CASCADE,
        related_name="media",
        db_index=True,
    )
    media_type = models.CharField(
        max_length=20,
        choices=MediaType.choices,
        default=MediaType.IMAGE,
        db_index=True,
    )
    file = models.FileField(upload_to="campaign_media/%Y/%m/")
    thumbnail = models.ImageField(
        upload_to="campaign_media/thumbnails/%Y/%m/",
        null=True,
        blank=True,
    )
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True, default="")
    file_size = models.BigIntegerField(default=0, help_text="File size in bytes")
    mime_type = models.CharField(max_length=100, blank=True, default="")
    duration_seconds = models.PositiveIntegerField(
        null=True,
        blank=True,
        help_text="Duration in seconds for video assets",
    )
    width = models.PositiveIntegerField(null=True, blank=True)
    height = models.PositiveIntegerField(null=True, blank=True)
    status = models.CharField(
        max_length=20,
        choices=MediaStatus.choices,
        default=MediaStatus.READY,
        db_index=True,
    )
    uploaded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="uploaded_campaign_media",
        db_index=True,
    )
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        verbose_name = "Campaign Media"
        verbose_name_plural = "Campaign Media Assets"
        indexes = [
            models.Index(fields=["campaign"], name="idx_media_campaign"),
            models.Index(fields=["media_type"], name="idx_media_type"),
            models.Index(fields=["status"], name="idx_media_status"),
            models.Index(fields=["uploaded_by"], name="idx_media_uploader"),
            models.Index(fields=["campaign", "status"], name="idx_media_camp_status"),
        ]

    def __str__(self):
        return f"[{self.get_media_type_display()}] {self.title} - {self.get_status_display()}"


class PlacementType(models.TextChoices):
    HOME_FEED = "HOME_FEED", "Home Feed"
    HEADER = "HEADER", "Header Banner"
    FOOTER = "FOOTER", "Footer Banner"
    POPUP = "POPUP", "Popup Advertisement"
    VIDEO_PREROLL = "VIDEO_PREROLL", "Video Pre-roll"
    TASK_FEED = "TASK_FEED", "Task Feed Section"


class PlacementStatus(models.TextChoices):
    DRAFT = "DRAFT", "Draft"
    ACTIVE = "ACTIVE", "Active"
    PAUSED = "PAUSED", "Paused"
    DISABLED = "DISABLED", "Disabled"


class CampaignAdPlacement(models.Model):
    """
    Advertisement Placement entity managing placement surfaces, priority,
    lifecycle state, and media linking for campaign advertising delivery.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    campaign = models.ForeignKey(
        Campaign,
        on_delete=models.CASCADE,
        related_name="placements",
        db_index=True,
    )
    media = models.ForeignKey(
        CampaignMedia,
        on_delete=models.CASCADE,
        related_name="placements",
        db_index=True,
    )
    placement_type = models.CharField(
        max_length=30,
        choices=PlacementType.choices,
        default=PlacementType.HOME_FEED,
        db_index=True,
    )
    status = models.CharField(
        max_length=20,
        choices=PlacementStatus.choices,
        default=PlacementStatus.DRAFT,
        db_index=True,
    )
    priority = models.PositiveIntegerField(
        default=10,
        help_text="Delivery priority weight (higher integer = served first)",
    )
    start_date = models.DateTimeField(null=True, blank=True)
    end_date = models.DateTimeField(null=True, blank=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="created_ad_placements",
        db_index=True,
    )
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-priority", "-created_at"]
        verbose_name = "Advertisement Placement"
        verbose_name_plural = "Advertisement Placements"
        indexes = [
            models.Index(fields=["placement_type"], name="idx_place_type"),
            models.Index(fields=["status"], name="idx_place_status"),
            models.Index(fields=["campaign"], name="idx_place_campaign"),
            models.Index(fields=["media"], name="idx_place_media"),
            models.Index(fields=["placement_type", "status"], name="idx_place_type_status"),
            models.Index(fields=["campaign", "status"], name="idx_place_camp_status"),
        ]

    def __str__(self):
        return f"[{self.get_placement_type_display()}] {self.campaign.title} ({self.get_status_display()})"


# Phase 5.5 Step 4: Advertisement Tracking and Analytics Models
from apps.campaigns.tracking.models import (
    ClickType,
    AdvertisementImpression,
    AdvertisementClick,
    AdvertisementVideoEngagement,
)


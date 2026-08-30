import uuid
from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _


class ClickType(models.TextChoices):
    BANNER_CLICK = "BANNER_CLICK", _("Banner Click")
    VIDEO_CLICK = "VIDEO_CLICK", _("Video Click")
    CALL_ACTION = "CALL_ACTION", _("Call to Action")
    EXTERNAL_LINK = "EXTERNAL_LINK", _("External Link")


class AdvertisementImpression(models.Model):
    """
    Stores individual server-validated advertisement display events.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    campaign = models.ForeignKey(
        "campaigns.Campaign",
        on_delete=models.CASCADE,
        related_name="ad_impressions",
        db_index=True,
    )
    placement = models.ForeignKey(
        "campaigns.CampaignAdPlacement",
        on_delete=models.CASCADE,
        related_name="ad_impressions",
        db_index=True,
    )
    media = models.ForeignKey(
        "campaigns.CampaignMedia",
        on_delete=models.CASCADE,
        related_name="ad_impressions",
        db_index=True,
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="ad_impressions",
        db_index=True,
    )
    session_id = models.CharField(max_length=255, db_index=True)
    device_id = models.CharField(max_length=255, null=True, blank=True, db_index=True)
    ip_hash = models.CharField(max_length=64, blank=True, default="")
    user_agent = models.TextField(blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table = "campaign_ad_impressions"
        ordering = ["-created_at"]
        verbose_name = "Advertisement Impression"
        verbose_name_plural = "Advertisement Impressions"
        indexes = [
            models.Index(fields=["campaign", "created_at"], name="idx_ad_imp_camp_time"),
            models.Index(fields=["placement", "created_at"], name="idx_ad_imp_place_time"),
            models.Index(fields=["media", "created_at"], name="idx_ad_imp_media_time"),
            models.Index(fields=["user", "created_at"], name="idx_ad_imp_user_time"),
            models.Index(fields=["session_id", "created_at"], name="idx_ad_imp_sess_time"),
        ]

    def __str__(self):
        return f"Impression {self.id} (Campaign: {self.campaign.title}, Placement: {self.placement.placement_type})"


class AdvertisementClick(models.Model):
    """
    Stores server-validated user interactions with an advertisement.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    impression = models.ForeignKey(
        AdvertisementImpression,
        on_delete=models.CASCADE,
        related_name="ad_clicks",
        null=True,
        blank=True,
        db_index=True,
    )
    campaign = models.ForeignKey(
        "campaigns.Campaign",
        on_delete=models.CASCADE,
        related_name="ad_clicks",
        db_index=True,
    )
    media = models.ForeignKey(
        "campaigns.CampaignMedia",
        on_delete=models.CASCADE,
        related_name="ad_clicks",
        db_index=True,
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="ad_clicks",
        db_index=True,
    )
    click_type = models.CharField(
        max_length=32,
        choices=ClickType.choices,
        default=ClickType.BANNER_CLICK,
        db_index=True,
    )
    session_id = models.CharField(max_length=255, blank=True, default="", db_index=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table = "campaign_ad_clicks"
        ordering = ["-created_at"]
        verbose_name = "Advertisement Click"
        verbose_name_plural = "Advertisement Clicks"
        indexes = [
            models.Index(fields=["campaign", "created_at"], name="idx_ad_clk_camp_time"),
            models.Index(fields=["media", "created_at"], name="idx_ad_clk_media_time"),
            models.Index(fields=["click_type", "created_at"], name="idx_ad_clk_type_time"),
        ]

    def __str__(self):
        return f"Click {self.id} [{self.get_click_type_display()}] on {self.campaign.title}"


class AdvertisementVideoEngagement(models.Model):
    """
    Tracks playback duration and completion percentage for video advertisements.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    campaign = models.ForeignKey(
        "campaigns.Campaign",
        on_delete=models.CASCADE,
        related_name="ad_video_engagements",
        db_index=True,
    )
    media = models.ForeignKey(
        "campaigns.CampaignMedia",
        on_delete=models.CASCADE,
        related_name="ad_video_engagements",
        db_index=True,
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="ad_video_engagements",
        db_index=True,
    )
    session_id = models.CharField(max_length=255, db_index=True)
    watched_seconds = models.FloatField(default=0.0)
    completion_percentage = models.FloatField(default=0.0)
    completed = models.BooleanField(default=False, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "campaign_ad_video_engagements"
        ordering = ["-updated_at"]
        verbose_name = "Video Ad Engagement"
        verbose_name_plural = "Video Ad Engagements"
        indexes = [
            models.Index(fields=["campaign", "created_at"], name="idx_ad_vid_camp_time"),
            models.Index(fields=["media", "created_at"], name="idx_ad_vid_media_time"),
            models.Index(fields=["session_id"], name="idx_ad_vid_session"),
            models.Index(fields=["completed"], name="idx_ad_vid_completed"),
        ]

    def __str__(self):
        status_text = "Completed" if self.completed else f"{self.completion_percentage:.1f}%"
        return f"VideoEngagement {self.session_id} - {self.media.title} ({status_text})"

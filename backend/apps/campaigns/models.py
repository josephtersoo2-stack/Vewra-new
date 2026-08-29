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

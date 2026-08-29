from decimal import Decimal
from django.core.exceptions import ValidationError, PermissionDenied
from django.utils import timezone
from .models import Campaign, CampaignStatus, CampaignType


class CampaignService:
    """
    Core domain service orchestrating the Campaign lifecycle, status state transitions,
    and business rule enforcement.
    """

    @staticmethod
    def create_campaign(
        owner,
        campaign_type: str,
        title: str,
        description: str = "",
        budget: Decimal = Decimal("0.00"),
        start_date=None,
        end_date=None,
    ) -> Campaign:
        """
        Creates a new Campaign in default DRAFT status.
        """
        if not title or not title.strip():
            raise ValidationError({"title": "Campaign title cannot be empty."})

        if campaign_type not in CampaignType.values:
            raise ValidationError({"campaign_type": f"Invalid campaign type: {campaign_type}."})

        if budget < Decimal("0.00"):
            raise ValidationError({"budget": "Budget cannot be negative."})

        if start_date and end_date and end_date <= start_date:
            raise ValidationError({"end_date": "End date must be after start date."})

        campaign = Campaign.objects.create(
            owner=owner,
            campaign_type=campaign_type,
            title=title.strip(),
            description=description.strip() if description else "",
            budget=budget,
            start_date=start_date,
            end_date=end_date,
            status=CampaignStatus.DRAFT,
        )
        return campaign

    @staticmethod
    def submit_for_review(campaign: Campaign, user) -> Campaign:
        """
        Transitions campaign from DRAFT (or REJECTED) to PENDING_REVIEW.
        Requires owner authentication.
        """
        is_admin = user.is_staff or getattr(user, "role", "") == "admin"
        if campaign.owner != user and not is_admin:
            raise PermissionDenied("Only the campaign owner can submit this campaign for review.")

        if campaign.status not in [CampaignStatus.DRAFT, CampaignStatus.REJECTED]:
            raise ValidationError(
                f"Cannot submit campaign in status '{campaign.status}' for review. Must be DRAFT or REJECTED."
            )

        campaign.status = CampaignStatus.PENDING_REVIEW
        campaign.save(update_fields=["status", "updated_at"])
        return campaign

    @staticmethod
    def approve_campaign(campaign: Campaign, admin_user) -> Campaign:
        """
        Approves a campaign in PENDING_REVIEW status, transitioning it to ACTIVE.
        Requires Administrator permissions.
        """
        is_admin = admin_user.is_staff or getattr(admin_user, "role", "") == "admin" or getattr(admin_user, "is_superuser", False)
        if not is_admin:
            raise PermissionDenied("Administrative privileges required to approve campaigns.")

        if campaign.status != CampaignStatus.PENDING_REVIEW:
            raise ValidationError(
                f"Cannot approve campaign in status '{campaign.status}'. Only PENDING_REVIEW campaigns can be approved."
            )

        campaign.status = CampaignStatus.ACTIVE
        if not campaign.start_date:
            campaign.start_date = timezone.now()
        campaign.save(update_fields=["status", "start_date", "updated_at"])
        return campaign

    @staticmethod
    def reject_campaign(campaign: Campaign, admin_user, reason: str = "") -> Campaign:
        """
        Rejects a campaign in PENDING_REVIEW status, transitioning it to REJECTED.
        Requires Administrator permissions.
        """
        is_admin = admin_user.is_staff or getattr(admin_user, "role", "") == "admin" or getattr(admin_user, "is_superuser", False)
        if not is_admin:
            raise PermissionDenied("Administrative privileges required to reject campaigns.")

        if campaign.status != CampaignStatus.PENDING_REVIEW:
            raise ValidationError(
                f"Cannot reject campaign in status '{campaign.status}'. Only PENDING_REVIEW campaigns can be rejected."
            )

        campaign.status = CampaignStatus.REJECTED
        campaign.save(update_fields=["status", "updated_at"])
        return campaign

    @staticmethod
    def pause_campaign(campaign: Campaign, user) -> Campaign:
        """
        Pauses an ACTIVE campaign, transitioning it to PAUSED.
        Authorized for owner or Administrator.
        """
        is_admin = user.is_staff or getattr(user, "role", "") == "admin"
        if campaign.owner != user and not is_admin:
            raise PermissionDenied("You do not have permission to pause this campaign.")

        if campaign.status != CampaignStatus.ACTIVE:
            raise ValidationError(
                f"Cannot pause campaign in status '{campaign.status}'. Only ACTIVE campaigns can be paused."
            )

        campaign.status = CampaignStatus.PAUSED
        campaign.save(update_fields=["status", "updated_at"])
        return campaign

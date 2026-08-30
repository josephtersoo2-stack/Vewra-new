from decimal import Decimal
from typing import Optional
from django.core.exceptions import ValidationError, PermissionDenied
from django.utils import timezone
from django.core.files.uploadedfile import UploadedFile

from .models import (
    Campaign,
    CampaignStatus,
    CampaignType,
    CampaignMedia,
    MediaType,
    MediaStatus,
    CampaignAdPlacement,
    PlacementType,
    PlacementStatus,
)
from django.db import models
from .permissions import is_advertiser_capable
from .media_services import MediaValidationService


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
        Requires owner to have advertiser capability or administrative status.
        """
        if not is_advertiser_capable(owner):
            raise PermissionDenied("Only verified advertiser accounts or administrators can create campaigns.")

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
        Requires Administrator privileges.
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
        Requires Administrator privileges.
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


class CampaignMediaService:
    """
    Service domain managing media upload, validation, inspection,
    soft deletion, and access lifecycle for campaign creative assets.
    """

    @staticmethod
    def create_media(
        campaign: Campaign,
        uploaded_by,
        file: UploadedFile,
        media_type: str,
        title: str,
        description: str = "",
    ) -> CampaignMedia:
        """
        Validates ownership, security specifications, and attaches a new
        CampaignMedia asset to the target campaign.
        """
        is_admin = uploaded_by.is_staff or getattr(uploaded_by, "role", "") == "admin"
        if campaign.owner != uploaded_by and not is_admin:
            raise PermissionDenied("You do not own this campaign and cannot upload media to it.")

        if not is_advertiser_capable(uploaded_by):
            raise PermissionDenied("Only verified advertiser accounts or administrators can upload campaign media.")

        if not title or not title.strip():
            raise ValidationError({"title": "Media title cannot be empty."})

        if media_type not in MediaType.values:
            raise ValidationError({"media_type": f"Invalid media type '{media_type}'."})

        # Server-side validation & inspection
        metadata = MediaValidationService.validate_and_inspect_file(file, media_type)

        media = CampaignMedia.objects.create(
            campaign=campaign,
            uploaded_by=uploaded_by,
            media_type=media_type,
            file=file,
            title=title.strip(),
            description=description.strip() if description else "",
            file_size=metadata["file_size"],
            mime_type=metadata["mime_type"],
            width=metadata["width"],
            height=metadata["height"],
            duration_seconds=metadata["duration_seconds"],
            status=MediaStatus.READY,
        )
        return media

    @staticmethod
    def update_media(
        media: CampaignMedia,
        user,
        title: Optional[str] = None,
        description: Optional[str] = None,
        status: Optional[str] = None,
    ) -> CampaignMedia:
        """
        Updates metadata on a CampaignMedia asset.
        Requires ownership or administrative role.
        """
        is_admin = user.is_staff or getattr(user, "role", "") == "admin"
        if media.campaign.owner != user and not is_admin:
            raise PermissionDenied("You do not have permission to modify this media asset.")

        update_fields = ["updated_at"]

        if title is not None and title.strip():
            media.title = title.strip()
            update_fields.append("title")

        if description is not None:
            media.description = description.strip()
            update_fields.append("description")

        if status is not None:
            if status not in MediaStatus.values:
                raise ValidationError({"status": f"Invalid media status '{status}'."})
            media.status = status
            update_fields.append("status")

        media.save(update_fields=update_fields)
        return media

    @staticmethod
    def disable_media(media: CampaignMedia, user) -> CampaignMedia:
        """
        Soft-disables media asset instead of permanent removal.
        """
        is_admin = user.is_staff or getattr(user, "role", "") == "admin"
        if media.campaign.owner != user and not is_admin:
            raise PermissionDenied("You do not have permission to disable this media asset.")

        media.status = MediaStatus.DISABLED
        media.save(update_fields=["status", "updated_at"])
        return media

    @staticmethod
    def restore_media(media: CampaignMedia, user) -> CampaignMedia:
        """
        Restores a disabled media asset back to READY status.
        """
        is_admin = user.is_staff or getattr(user, "role", "") == "admin"
        if media.campaign.owner != user and not is_admin:
            raise PermissionDenied("You do not have permission to restore this media asset.")

        media.status = MediaStatus.READY
        media.save(update_fields=["status", "updated_at"])
        return media

    @staticmethod
    def list_campaign_media(
        campaign: Campaign,
        user,
        media_type: Optional[str] = None,
        status: Optional[str] = None,
    ):
        """
        Lists media for a campaign with strict security checks.
        Advertisers can only view media for their own campaigns.
        """
        is_admin = user and (user.is_staff or getattr(user, "role", "") == "admin")
        if user and campaign.owner != user and not is_admin:
            # Check if campaign is active and media is active for public inspection
            if campaign.status != CampaignStatus.ACTIVE:
                raise PermissionDenied("You do not have access to view this campaign's media assets.")

        qs = campaign.media.all().select_related("uploaded_by")

        if not is_admin and (not user or campaign.owner != user):
            # Non-owners only see READY media
            qs = qs.filter(status=MediaStatus.READY)

        if media_type and media_type.upper() in MediaType.values:
            qs = qs.filter(media_type=media_type.upper())

        if status and status.upper() in MediaStatus.values:
            qs = qs.filter(status=status.upper())

        return qs


class CampaignAdDeliveryService:
    """
    Core domain service managing advertisement placements, surface routing,
    priority weighting, and server-authoritative ad delivery.
    """

    @staticmethod
    def create_placement(
        user,
        campaign_id,
        media_id,
        placement_type: str,
        priority: int = 10,
        start_date=None,
        end_date=None,
        status: str = PlacementStatus.DRAFT,
    ) -> CampaignAdPlacement:
        """
        Creates an advertisement placement linking approved campaign media to a surface.
        Validates ownership, capability, media ownership, and READY media status.
        """
        is_admin = user.is_staff or getattr(user, "role", "") == "admin" or getattr(user, "is_superuser", False)
        if not is_advertiser_capable(user) and not is_admin:
            raise PermissionDenied("Only verified advertiser accounts or administrators can create advertisement placements.")

        try:
            campaign = Campaign.objects.get(id=campaign_id)
        except (Campaign.DoesNotExist, ValueError):
            raise ValidationError({"campaign": f"Campaign '{campaign_id}' does not exist."})

        if campaign.owner != user and not is_admin:
            raise PermissionDenied("You do not own this campaign and cannot create placements for it.")

        try:
            media = CampaignMedia.objects.get(id=media_id)
        except (CampaignMedia.DoesNotExist, ValueError):
            raise ValidationError({"media": f"Media asset '{media_id}' does not exist."})

        if media.campaign_id != campaign.id:
            raise ValidationError({"media": "Selected media asset does not belong to this campaign."})

        if media.status != MediaStatus.READY:
            raise ValidationError({"media": f"Cannot attach media in status '{media.status}'. Only READY media assets can be attached."})

        if placement_type not in PlacementType.values:
            raise ValidationError({"placement_type": f"Invalid placement type: '{placement_type}'."})

        if status not in PlacementStatus.values:
            raise ValidationError({"status": f"Invalid placement status: '{status}'."})

        if start_date and end_date and end_date <= start_date:
            raise ValidationError({"end_date": "End date must be after start date."})

        # If created directly as ACTIVE, campaign must be ACTIVE
        if status == PlacementStatus.ACTIVE:
            if campaign.status != CampaignStatus.ACTIVE:
                raise ValidationError({"status": f"Cannot create active placement: Campaign is in '{campaign.status}' status (must be ACTIVE)."})
            if end_date and end_date < timezone.now():
                raise ValidationError({"end_date": "Cannot activate placement: End date is in the past."})

        placement = CampaignAdPlacement.objects.create(
            campaign=campaign,
            media=media,
            placement_type=placement_type,
            status=status,
            priority=priority,
            start_date=start_date,
            end_date=end_date,
            created_by=user,
        )
        return placement

    @staticmethod
    def activate_placement(user, placement: CampaignAdPlacement) -> CampaignAdPlacement:
        """
        Activates an advertisement placement.
        Validates campaign ACTIVE status, media READY status, and validity dates.
        """
        is_admin = user.is_staff or getattr(user, "role", "") == "admin" or getattr(user, "is_superuser", False)
        if placement.campaign.owner != user and not is_admin:
            raise PermissionDenied("You do not have permission to activate this placement.")

        if placement.campaign.status != CampaignStatus.ACTIVE:
            raise ValidationError(
                f"Cannot activate placement: Campaign is in '{placement.campaign.status}' status (must be ACTIVE)."
            )

        if placement.media.status != MediaStatus.READY:
            raise ValidationError(
                f"Cannot activate placement: Attached media is in '{placement.media.status}' status (must be READY)."
            )

        now = timezone.now()
        if placement.end_date and placement.end_date < now:
            raise ValidationError("Cannot activate placement: End date has already expired.")

        placement.status = PlacementStatus.ACTIVE
        if not placement.start_date:
            placement.start_date = now
        placement.save(update_fields=["status", "start_date", "updated_at"])
        return placement

    @staticmethod
    def pause_placement(user, placement: CampaignAdPlacement) -> CampaignAdPlacement:
        """
        Pauses an ACTIVE advertisement placement.
        """
        is_admin = user.is_staff or getattr(user, "role", "") == "admin" or getattr(user, "is_superuser", False)
        if placement.campaign.owner != user and not is_admin:
            raise PermissionDenied("You do not have permission to pause this placement.")

        if placement.status not in [PlacementStatus.ACTIVE, PlacementStatus.DRAFT]:
            raise ValidationError(f"Cannot pause placement in status '{placement.status}'.")

        placement.status = PlacementStatus.PAUSED
        placement.save(update_fields=["status", "updated_at"])
        return placement

    @staticmethod
    def disable_placement(user, placement: CampaignAdPlacement) -> CampaignAdPlacement:
        """
        Soft-disables an advertisement placement.
        """
        is_admin = user.is_staff or getattr(user, "role", "") == "admin" or getattr(user, "is_superuser", False)
        if placement.campaign.owner != user and not is_admin:
            raise PermissionDenied("You do not have permission to disable this placement.")

        placement.status = PlacementStatus.DISABLED
        placement.save(update_fields=["status", "updated_at"])
        return placement

    @staticmethod
    def restore_placement(user, placement: CampaignAdPlacement) -> CampaignAdPlacement:
        """
        Restores a disabled advertisement placement back to DRAFT or ACTIVE.
        """
        is_admin = user.is_staff or getattr(user, "role", "") == "admin" or getattr(user, "is_superuser", False)
        if placement.campaign.owner != user and not is_admin:
            raise PermissionDenied("You do not have permission to restore this placement.")

        if placement.campaign.status == CampaignStatus.ACTIVE and placement.media.status == MediaStatus.READY:
            placement.status = PlacementStatus.ACTIVE
        else:
            placement.status = PlacementStatus.DRAFT

        placement.save(update_fields=["status", "updated_at"])
        return placement

    @staticmethod
    def update_placement(
        user,
        placement: CampaignAdPlacement,
        placement_type: Optional[str] = None,
        media_id: Optional[str] = None,
        priority: Optional[int] = None,
        start_date=None,
        end_date=None,
        status: Optional[str] = None,
    ) -> CampaignAdPlacement:
        """
        Updates an existing advertisement placement.
        """
        is_admin = user.is_staff or getattr(user, "role", "") == "admin" or getattr(user, "is_superuser", False)
        if placement.campaign.owner != user and not is_admin:
            raise PermissionDenied("You do not have permission to modify this placement.")

        update_fields = ["updated_at"]

        if placement_type is not None:
            if placement_type not in PlacementType.values:
                raise ValidationError({"placement_type": f"Invalid placement type '{placement_type}'."})
            placement.placement_type = placement_type
            update_fields.append("placement_type")

        if media_id is not None:
            try:
                media = CampaignMedia.objects.get(id=media_id)
            except (CampaignMedia.DoesNotExist, ValueError):
                raise ValidationError({"media": f"Media asset '{media_id}' does not exist."})
            if media.campaign_id != placement.campaign_id:
                raise ValidationError({"media": "Selected media asset does not belong to this campaign."})
            if media.status != MediaStatus.READY:
                raise ValidationError({"media": f"Cannot attach media in status '{media.status}'. Must be READY."})
            placement.media = media
            update_fields.append("media")

        if priority is not None:
            placement.priority = int(priority)
            update_fields.append("priority")

        if start_date is not None:
            placement.start_date = start_date
            update_fields.append("start_date")

        if end_date is not None:
            placement.end_date = end_date
            update_fields.append("end_date")

        if status is not None:
            if status == PlacementStatus.ACTIVE:
                CampaignAdDeliveryService.activate_placement(user, placement)
                return placement
            elif status == PlacementStatus.PAUSED:
                CampaignAdDeliveryService.pause_placement(user, placement)
                return placement
            elif status == PlacementStatus.DISABLED:
                CampaignAdDeliveryService.disable_placement(user, placement)
                return placement
            elif status == PlacementStatus.DRAFT:
                placement.status = PlacementStatus.DRAFT
                update_fields.append("status")
            else:
                raise ValidationError({"status": f"Invalid placement status '{status}'."})

        placement.save(update_fields=update_fields)
        return placement

    @staticmethod
    def get_active_ads_by_location(placement_type: str, limit: int = 10):
        """
        Server-authoritative delivery engine for approved ads on application surfaces.
        Only returns active placements for active campaigns with READY media.
        """
        if placement_type.upper() not in PlacementType.values:
            raise ValidationError(f"Invalid placement type '{placement_type}'.")

        now = timezone.now()
        qs = (
            CampaignAdPlacement.objects.filter(
                placement_type=placement_type.upper(),
                status=PlacementStatus.ACTIVE,
                campaign__status=CampaignStatus.ACTIVE,
                media__status=MediaStatus.READY,
            )
            .filter(models.Q(start_date__isnull=True) | models.Q(start_date__lte=now))
            .filter(models.Q(end_date__isnull=True) | models.Q(end_date__gte=now))
            .select_related("campaign", "media", "campaign__owner")
            .order_by("-priority", "-created_at")[:limit]
        )
        return qs

    @staticmethod
    def list_campaign_placements(
        user,
        campaign_id: Optional[str] = None,
        placement_type: Optional[str] = None,
        status: Optional[str] = None,
    ):
        """
        Lists placements with tenant isolation.
        Advertisers only see placements for their own campaigns.
        Admins can inspect placements across all campaigns.
        """
        is_admin = user and (user.is_staff or getattr(user, "role", "") == "admin")
        qs = CampaignAdPlacement.objects.all().select_related("campaign", "media", "created_by", "campaign__owner")

        if campaign_id:
            qs = qs.filter(campaign_id=campaign_id)

        if not is_admin:
            if not user or not user.is_authenticated:
                raise PermissionDenied("Authentication required to list campaign placements.")
            qs = qs.filter(campaign__owner=user)

        if placement_type and placement_type.upper() in PlacementType.values:
            qs = qs.filter(placement_type=placement_type.upper())

        if status and status.upper() in PlacementStatus.values:
            qs = qs.filter(status=status.upper())

        return qs


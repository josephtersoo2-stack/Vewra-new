from django.core.exceptions import PermissionDenied
from apps.campaigns.models import Campaign
from apps.campaigns.permissions import is_advertiser_capable
from apps.campaigns.tracking.models import (
    AdvertisementImpression,
    AdvertisementClick,
    AdvertisementVideoEngagement,
)
from apps.campaigns.tracking.services import AdvertisementTrackingService


def get_campaign_analytics(campaign_id, user=None):
    """
    Returns aggregated statistics dictionary for a specific campaign.
    """
    return AdvertisementTrackingService.generate_campaign_statistics(campaign_id, user=user)


def get_advertiser_overview_analytics(user):
    """
    Returns aggregated dashboard analytics for the authenticated advertiser or admin.
    """
    return AdvertisementTrackingService.generate_advertiser_overview(user)


def list_campaign_impressions(campaign_id, user=None):
    """
    Returns queryset of impressions for a campaign, ensuring tenant isolation.
    """
    campaign = Campaign.objects.get(id=campaign_id)
    if user and not (user.is_staff or user.is_superuser):
        if not is_advertiser_capable(user) or str(campaign.owner_id) != str(user.id):
            raise PermissionDenied("You do not have permission to view impressions for this campaign.")
    return AdvertisementImpression.objects.filter(campaign=campaign).select_related("placement", "media", "user")


def list_campaign_clicks(campaign_id, user=None):
    """
    Returns queryset of clicks for a campaign, ensuring tenant isolation.
    """
    campaign = Campaign.objects.get(id=campaign_id)
    if user and not (user.is_staff or user.is_superuser):
        if not is_advertiser_capable(user) or str(campaign.owner_id) != str(user.id):
            raise PermissionDenied("You do not have permission to view clicks for this campaign.")
    return AdvertisementClick.objects.filter(campaign=campaign).select_related("media", "user", "impression")

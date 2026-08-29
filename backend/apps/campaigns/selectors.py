from django.db.models import QuerySet
from .models import Campaign, CampaignStatus, CampaignType


def get_campaign_by_id(campaign_id) -> Campaign | None:
    """
    Retrieves a single campaign by primary key UUID with owner pre-joined.
    """
    try:
        return Campaign.objects.select_related("owner").get(id=campaign_id)
    except Campaign.DoesNotExist:
        return None


def list_campaigns(
    user=None,
    status: str = None,
    campaign_type: str = None,
    search: str = None,
    is_admin: bool = False,
) -> QuerySet[Campaign]:
    """
    Lists campaigns with optional filtering.
    Non-admin users can view their own campaigns across all statuses, plus all public ACTIVE campaigns.
    Admins can view all campaigns across all statuses.
    """
    qs = Campaign.objects.select_related("owner").all()

    if not is_admin:
        if user and user.is_authenticated:
            # User can see own campaigns OR any public active campaigns
            from django.db.models import Q
            qs = qs.filter(Q(owner=user) | Q(status=CampaignStatus.ACTIVE))
        else:
            # Unauthenticated callers only see ACTIVE campaigns
            qs = qs.filter(status=CampaignStatus.ACTIVE)

    if status and status.upper() in CampaignStatus.values:
        qs = qs.filter(status=status.upper())

    if campaign_type and campaign_type.upper() in CampaignType.values:
        qs = qs.filter(campaign_type=campaign_type.upper())

    if search and search.strip():
        qs = qs.filter(title__icontains=search.strip())

    return qs

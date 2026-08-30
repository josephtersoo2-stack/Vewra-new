from rest_framework import permissions
from apps.campaigns.permissions import is_advertiser_capable


class CanViewCampaignAnalytics(permissions.BasePermission):
    """
    Ensures that only the campaign owner (with advertiser capability)
    or platform administrators can view campaign tracking metrics and analytics.
    """

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated)

    def has_object_permission(self, request, view, obj):
        if request.user.is_staff or request.user.is_superuser:
            return True

        if not is_advertiser_capable(request.user):
            return False

        # If obj is Campaign
        if hasattr(obj, "owner_id"):
            return str(obj.owner_id) == str(request.user.id)

        # If obj has campaign relationship
        if hasattr(obj, "campaign"):
            return str(obj.campaign.owner_id) == str(request.user.id)

        return False


class CanViewAdvertiserOverview(permissions.BasePermission):
    """
    Permission allowing staff or verified advertiser users to view high-level analytics overviews.
    """

    def has_permission(self, request, view):
        if not (request.user and request.user.is_authenticated):
            return False
        if request.user.is_staff or request.user.is_superuser:
            return True
        return is_advertiser_capable(request.user)

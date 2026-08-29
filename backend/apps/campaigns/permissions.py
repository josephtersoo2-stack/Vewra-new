from rest_framework import permissions
from .models import CampaignStatus


def is_advertiser_capable(user) -> bool:
    """
    Clean extension hook evaluating whether a user account has advertiser capability.
    Allows administrators, staff, users with role='advertiser', or users with is_advertiser=True.
    Ordinary users without advertiser credentials are not authorized to create campaigns.
    """
    if not (user and user.is_authenticated):
        return False
    if user.is_staff or getattr(user, 'is_superuser', False) or getattr(user, 'role', '') == 'admin':
        return True
    if getattr(user, 'role', '') == 'advertiser':
        return True
    if getattr(user, 'is_advertiser', False):
        return True
    # Future extension point: advertiser verification / KYC check
    profile = getattr(user, 'profile', None)
    if profile and (getattr(profile, 'is_advertiser', False) or getattr(profile, 'role', '') == 'advertiser'):
        return True
    return False


class CanCreateCampaign(permissions.BasePermission):
    """
    Permission gate allowing only advertiser-capable accounts, staff, or admins
    to create new campaigns. Ordinary users are blocked.
    """
    message = "Only verified advertiser accounts or administrators can create campaigns."

    def has_permission(self, request, view):
        return is_advertiser_capable(request.user)


class IsCampaignOwner(permissions.BasePermission):
    """
    Object-level permission allowing only the owner of a campaign to view
    and edit their own DRAFT campaigns. Prevents editing approved/active campaigns
    or unauthorized state transitions.
    """

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated)

    def has_object_permission(self, request, view, obj):
        # Admin and staff have full oversight
        if request.user.is_staff or getattr(request.user, 'role', '') == 'admin':
            return True

        # Check ownership
        if obj.owner != request.user:
            return False

        # Read-only methods allowed for owner
        if request.method in permissions.SAFE_METHODS:
            return True

        # Owner can only edit DRAFT campaigns
        if request.method in ['PUT', 'PATCH', 'DELETE']:
            return obj.status == CampaignStatus.DRAFT

        return True


class IsAdminCampaignManager(permissions.BasePermission):
    """
    Permission allowing only designated administrators or staff to view all campaigns,
    approve, reject, or pause campaigns platform-wide.
    """

    def has_permission(self, request, view):
        if not (request.user and request.user.is_authenticated):
            return False
        return bool(
            request.user.is_staff
            or getattr(request.user, 'role', '') == 'admin'
            or getattr(request.user, 'is_superuser', False)
        )

    def has_object_permission(self, request, view, obj):
        return self.has_permission(request, view)

from rest_framework import permissions
from .models import CampaignStatus, MediaStatus


def is_advertiser_capable(user) -> bool:
    """
    Clean extension hook evaluating whether a user account has advertiser capability.
    Allows administrators, staff, users with role='advertiser', or users with is_advertiser=True.
    Ordinary users without advertiser credentials are not authorized to create campaigns.
    """
    if not (user and user.is_authenticated):
        return False
    if user.is_staff or getattr(user, 'is_superuser', False) or str(getattr(user, 'role', '')).lower() == 'admin':
        return True
    if str(getattr(user, 'role', '')).lower() == 'advertiser':
        return True
    if getattr(user, 'is_advertiser', False):
        return True
    # Future extension point: advertiser verification / KYC check
    profile = getattr(user, 'profile', None)
    if profile and (getattr(profile, 'is_advertiser', False) or str(getattr(profile, 'role', '')).lower() == 'advertiser'):
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


class IsCampaignMediaOwnerOrAdmin(permissions.BasePermission):
    """
    Object-level permission ensuring:
    - Admins and staff have full access.
    - Campaign owner can view, update, and soft-delete (disable) their own campaign media.
    - Another advertiser or normal user CANNOT access, update, or disable this media.
    """

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated)

    def has_object_permission(self, request, view, obj):
        # obj is CampaignMedia
        if request.user.is_staff or getattr(request.user, 'role', '') == 'admin':
            return True

        # Check campaign ownership
        if obj.campaign.owner == request.user:
            return True

        # Read-only access for public active campaign assets
        if request.method in permissions.SAFE_METHODS and obj.campaign.status == CampaignStatus.ACTIVE and obj.status == MediaStatus.READY:
            return True

        return False


class IsCampaignPlacementOwnerOrAdmin(permissions.BasePermission):
    """
    Object-level permission ensuring:
    - Admins and staff have full access.
    - Campaign owner can view, update, pause, disable, and restore their own placements.
    - Another advertiser or normal user CANNOT modify or view non-public placements.
    """

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated)

    def has_object_permission(self, request, view, obj):
        # obj is CampaignAdPlacement
        if request.user.is_staff or getattr(request.user, 'role', '') == 'admin' or getattr(request.user, 'is_superuser', False):
            return True

        # Campaign owner
        if obj.campaign.owner == request.user:
            return True

        return False


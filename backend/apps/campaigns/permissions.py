from rest_framework import permissions
from .models import CampaignStatus


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

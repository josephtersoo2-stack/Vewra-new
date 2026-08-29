from rest_framework import permissions

class IsAdminOrStaff(permissions.BasePermission):
    """
    Permission check for Admin Portal endpoints.
    Allows access only to authenticated staff or superusers.
    """
    def has_permission(self, request, view):
        return bool(
            request.user and
            request.user.is_authenticated and
            (request.user.is_staff or request.user.is_superuser)
        )

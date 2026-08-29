from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import User, UserProfile, UserPreference, UserStatistics
from .serializers import (
    UserSerializer,
    PublicUserProfileSerializer,
    UserProfileUpdateSerializer,
    UserPreferenceSerializer,
    UserStatisticsSerializer,
)
from .services import UserService

class UserProfileView(APIView):
    """API endpoint to retrieve the current authenticated user's complete profile."""

    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        serializer = UserSerializer(request.user, context={'request': request})
        return Response(
            {
                'status': 'success',
                'user': serializer.data,
            },
            status=status.HTTP_200_OK
        )


class UserProfileUpdateView(APIView):
    """API endpoint to update user profile information."""

    permission_classes = (permissions.IsAuthenticated,)

    def patch(self, request, *args, **kwargs):
        serializer = UserProfileUpdateSerializer(
            instance=request.user,
            data=request.data,
            partial=True,
            context={'request': request}
        )
        if serializer.is_valid():
            user = serializer.save()
            return Response(
                {
                    'status': 'success',
                    'message': 'Profile updated successfully.',
                    'user': UserSerializer(user, context={'request': request}).data,
                },
                status=status.HTTP_200_OK
            )
        return Response(
            {
                'status': 'error',
                'errors': serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST
        )

    def put(self, request, *args, **kwargs):
        return self.patch(request, *args, **kwargs)


class PublicUserProfileView(APIView):
    """API endpoint to view another user's public profile and statistics."""

    permission_classes = (permissions.AllowAny,)

    def get(self, request, username, *args, **kwargs):
        user = UserService.get_user_by_username(username)
        if not user:
            return Response(
                {
                    'status': 'error',
                    'message': 'User not found',
                },
                status=status.HTTP_404_NOT_FOUND
            )
        serializer = PublicUserProfileSerializer(user)
        return Response(
            {
                'status': 'success',
                'user': serializer.data,
            },
            status=status.HTTP_200_OK
        )


class UserStatisticsView(APIView):
    """API endpoint to fetch current user's aggregated statistics."""

    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        stats, _ = UserStatistics.objects.get_or_create(user=request.user)
        serializer = UserStatisticsSerializer(stats)
        return Response(
            {
                'status': 'success',
                'statistics': serializer.data,
            },
            status=status.HTTP_200_OK
        )


class UserPreferenceView(APIView):
    """API endpoint to get or update user preferences."""

    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        prefs, _ = UserPreference.objects.get_or_create(user=request.user)
        serializer = UserPreferenceSerializer(prefs)
        return Response(
            {
                'status': 'success',
                'preferences': serializer.data,
            },
            status=status.HTTP_200_OK
        )

    def patch(self, request, *args, **kwargs):
        prefs, _ = UserPreference.objects.get_or_create(user=request.user)
        serializer = UserPreferenceSerializer(instance=prefs, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(
                {
                    'status': 'success',
                    'message': 'Preferences updated successfully.',
                    'preferences': serializer.data,
                },
                status=status.HTTP_200_OK
            )
        return Response(
            {
                'status': 'error',
                'errors': serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST
        )

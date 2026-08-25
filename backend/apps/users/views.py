from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from .serializers import UserSerializer, UserUpdateSerializer

class UserProfileView(APIView):
    """API endpoint to retrieve the current authenticated user's profile."""

    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        user = request.user
        serializer = UserSerializer(user)
        return Response(
            {
                'status': 'success',
                'user': serializer.data,
            },
            status=status.HTTP_200_OK
        )


class UserUpdateView(APIView):
    """API endpoint to update the current authenticated user's details."""

    permission_classes = (permissions.IsAuthenticated,)

    def put(self, request, *args, **kwargs):
        return self._update(request, partial=False)

    def patch(self, request, *args, **kwargs):
        return self._update(request, partial=True)

    def _update(self, request, partial=True):
        serializer = UserUpdateSerializer(
            instance=request.user,
            data=request.data,
            partial=partial,
            context={'request': request}
        )
        if serializer.is_valid():
            user = serializer.save()
            return Response(
                {
                    'status': 'success',
                    'message': 'Profile updated successfully.',
                    'user': UserSerializer(user).data,
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

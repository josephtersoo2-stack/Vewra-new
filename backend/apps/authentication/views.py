from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenRefreshView as BaseTokenRefreshView
from apps.users.serializers import UserSerializer
from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    LogoutSerializer,
    PasswordResetRequestSerializer,
    PasswordResetConfirmSerializer,
)
from .services import AuthService

class RegisterView(APIView):
    """API endpoint for new user registration."""

    permission_classes = (permissions.AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            tokens = AuthService.get_tokens_for_user(user)
            user_data = UserSerializer(user, context={'request': request}).data
            return Response(
                {
                    'status': 'success',
                    'message': 'Account created successfully.',
                    'tokens': tokens,
                    'user': user_data,
                },
                status=status.HTTP_201_CREATED
            )
        return Response(
            {
                'status': 'error',
                'message': 'Validation failed',
                'errors': serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST
        )


class LoginView(APIView):
    """API endpoint for user authentication."""

    permission_classes = (permissions.AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = LoginSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            user = serializer.validated_data['user']
            tokens = AuthService.get_tokens_for_user(user)
            user_data = UserSerializer(user, context={'request': request}).data
            return Response(
                {
                    'status': 'success',
                    'message': 'Login successful.',
                    'tokens': tokens,
                    'user': user_data,
                },
                status=status.HTTP_200_OK
            )
        return Response(
            {
                'status': 'error',
                'message': 'Invalid credentials',
                'errors': serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST
        )


class LogoutView(APIView):
    """API endpoint for user logout and refresh token blacklisting."""

    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, *args, **kwargs):
        serializer = LogoutSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(
                {
                    'status': 'success',
                    'message': 'Logged out successfully.',
                },
                status=status.HTTP_200_OK
            )
        return Response(
            {
                'status': 'error',
                'message': 'Invalid token provided',
                'errors': serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST
        )


class TokenRefreshView(BaseTokenRefreshView):
    """API endpoint to refresh expired JWT access token."""

    permission_classes = (permissions.AllowAny,)


class PasswordResetRequestView(APIView):
    """API endpoint to request password reset code/token."""

    permission_classes = (permissions.AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = PasswordResetRequestSerializer(data=request.data)
        if serializer.is_valid():
            # In a full mail service, send reset token email here.
            # In dev, we return success without leaking email existence.
            return Response(
                {
                    'status': 'success',
                    'message': 'If the email exists, a password reset link has been dispatched.',
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


class PasswordResetConfirmView(APIView):
    """API endpoint to confirm password reset."""

    permission_classes = (permissions.AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            new_password = serializer.validated_data['new_password']
            user.set_password(new_password)
            user.save()
            return Response(
                {
                    'status': 'success',
                    'message': 'Password has been reset successfully.',
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

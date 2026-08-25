from django.contrib.auth import authenticate
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken
from apps.users.models import User
from apps.users.serializers import UserSerializer

class RegisterSerializer(serializers.Serializer):
    """Serializer for new user account registration."""

    email = serializers.EmailField(required=True)
    username = serializers.CharField(required=True, min_length=3, max_length=50)
    password = serializers.CharField(required=True, min_length=6, write_only=True)
    country = serializers.CharField(required=False, default='Global')
    phone_number = serializers.CharField(required=False, allow_blank=True, default='')

    def validate_email(self, value):
        normalized = value.strip().lower()
        if User.objects.filter(email__iexact=normalized).exists():
            raise serializers.ValidationError('A user with this email already exists.')
        return normalized

    def validate_username(self, value):
        clean_user = value.strip()
        if User.objects.filter(username__iexact=clean_user).exists():
            raise serializers.ValidationError('This username is already taken.')
        return clean_user

    def create(self, validated_data):
        user = User.objects.create_user(
            email=validated_data['email'],
            username=validated_data['username'],
            password=validated_data['password'],
            country=validated_data.get('country', 'Global'),
            phone_number=validated_data.get('phone_number', '')
        )
        return user


class LoginSerializer(serializers.Serializer):
    """Serializer for user authentication with JWT token generation."""

    email = serializers.EmailField(required=True)
    password = serializers.CharField(required=True, write_only=True)

    def validate(self, attrs):
        email = attrs.get('email', '').strip().lower()
        password = attrs.get('password')

        if not email or not password:
            raise serializers.ValidationError('Must include email and password.')

        user = authenticate(
            request=self.context.get('request'),
            email=email,
            password=password
        )

        if not user:
            raise serializers.ValidationError('Invalid email or password.')

        if not user.is_active:
            raise serializers.ValidationError('User account is disabled.')

        attrs['user'] = user
        return attrs


class LogoutSerializer(serializers.Serializer):
    """Serializer for token revocation upon logout."""

    refresh = serializers.CharField(required=True)

    def validate(self, attrs):
        self.token = attrs['refresh']
        return attrs

    def save(self, **kwargs):
        try:
            token = RefreshToken(self.token)
            token.blacklist()
        except Exception:
            # Token may already be blacklisted or expired
            pass


class PasswordResetRequestSerializer(serializers.Serializer):
    """Serializer to request password reset code/token."""

    email = serializers.EmailField(required=True)

    def validate_email(self, value):
        normalized = value.strip().lower()
        if not User.objects.filter(email__iexact=normalized).exists():
            # For security, do not leak whether an email exists, but allow validation
            pass
        return normalized


class PasswordResetConfirmSerializer(serializers.Serializer):
    """Serializer to confirm password reset."""

    email = serializers.EmailField(required=True)
    token = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True, min_length=6)

    def validate(self, attrs):
        email = attrs.get('email', '').strip().lower()
        try:
            user = User.objects.get(email=email)
            attrs['user'] = user
        except User.DoesNotExist:
            raise serializers.ValidationError('Invalid password reset request.')
        return attrs

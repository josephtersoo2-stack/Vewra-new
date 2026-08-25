from rest_framework import serializers
from .models import User, UserProfile

class UserProfileSerializer(serializers.ModelSerializer):
    """Serializer for extended user ecosystem profile."""

    class Meta:
        model = UserProfile
        fields = (
            'level',
            'xp',
            'xp_next_level',
            'trust_score',
            'verification_status',
            'subscription_tier',
            'streak_days',
            'total_coins',
            'fiat_balance',
            'tasks_completed',
            'avatar',
            'created_at',
            'updated_at',
        )
        read_only_fields = (
            'level',
            'xp',
            'xp_next_level',
            'trust_score',
            'verification_status',
            'subscription_tier',
            'streak_days',
            'total_coins',
            'fiat_balance',
            'tasks_completed',
            'created_at',
            'updated_at',
        )


class UserSerializer(serializers.ModelSerializer):
    """Public user serializer with nested ecosystem profile."""

    profile = UserProfileSerializer(read_only=True)

    class Meta:
        model = User
        fields = (
            'id',
            'email',
            'username',
            'phone_number',
            'country',
            'currency',
            'timezone',
            'is_verified',
            'created_at',
            'profile',
        )
        read_only_fields = ('id', 'is_verified', 'created_at', 'profile')


class UserUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating user account details."""

    class Meta:
        model = User
        fields = ('username', 'phone_number', 'country', 'currency', 'timezone')

    def validate_username(self, value):
        user = self.context['request'].user
        if User.objects.exclude(pk=user.pk).filter(username__iexact=value).exists():
            raise serializers.ValidationError('This username is already taken.')
        return value

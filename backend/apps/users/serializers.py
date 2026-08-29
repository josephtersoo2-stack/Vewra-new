from rest_framework import serializers
from .models import User, UserProfile, UserPreference, UserStatistics

class UserPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserPreference
        fields = (
            'theme',
            'language',
            'notification_enabled',
            'email_notifications',
            'push_notifications',
            'updated_at',
        )


class UserStatisticsSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserStatistics
        fields = (
            'tasks_completed',
            'videos_watched',
            'quizzes_completed',
            'comments_created',
            'referrals',
            'total_rewards',
            'updated_at',
        )


class UserProfileSerializer(serializers.ModelSerializer):
    """Serializer for extended user ecosystem profile."""

    avatar = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = (
            'display_name',
            'bio',
            'country',
            'city',
            'language',
            'currency',
            'timezone',
            'date_of_birth',
            'gender',
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

    def get_avatar(self, obj):
        if obj.avatar:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.avatar.url)
            return obj.avatar.url
        return None


class UserSerializer(serializers.ModelSerializer):
    """Full private user serializer with profile, preferences, and statistics."""

    profile = UserProfileSerializer(read_only=True)
    preferences = UserPreferenceSerializer(read_only=True)
    statistics = UserStatisticsSerializer(read_only=True)

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
            'is_staff',
            'is_superuser',
            'created_at',
            'profile',
            'preferences',
            'statistics',
        )
        read_only_fields = (
            'id',
            'is_verified',
            'is_staff',
            'is_superuser',
            'created_at',
            'profile',
            'preferences',
            'statistics',
        )


class PublicUserProfileSerializer(serializers.ModelSerializer):
    """Public profile view for other community members."""

    profile = UserProfileSerializer(read_only=True)
    statistics = UserStatisticsSerializer(read_only=True)

    class Meta:
        model = User
        fields = (
            'id',
            'username',
            'country',
            'is_verified',
            'created_at',
            'profile',
            'statistics',
        )


class UserProfileUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating user account and profile attributes."""

    display_name = serializers.CharField(required=False, allow_blank=True)
    bio = serializers.CharField(required=False, allow_blank=True)
    country = serializers.CharField(required=False)
    city = serializers.CharField(required=False, allow_blank=True)
    language = serializers.CharField(required=False)
    currency = serializers.CharField(required=False)
    timezone = serializers.CharField(required=False)
    gender = serializers.CharField(required=False)
    date_of_birth = serializers.DateField(required=False, allow_null=True)
    avatar = serializers.ImageField(required=False, allow_null=True)

    class Meta:
        model = User
        fields = (
            'phone_number',
            'display_name',
            'bio',
            'country',
            'city',
            'language',
            'currency',
            'timezone',
            'gender',
            'date_of_birth',
            'avatar',
        )

    def update(self, instance, validated_data):
        profile_fields = [
            'display_name', 'bio', 'city', 'language', 'gender', 'date_of_birth', 'avatar'
        ]
        shared_fields = ['country', 'currency', 'timezone']

        profile_data = {}
        for field in profile_fields:
            if field in validated_data:
                profile_data[field] = validated_data.pop(field)

        for field in shared_fields:
            if field in validated_data:
                val = validated_data[field]
                setattr(instance, field, val)
                profile_data[field] = val

        # Update remaining User fields
        for attr, value in validated_data.items():
            if hasattr(instance, attr):
                setattr(instance, attr, value)
        instance.save()

        # Update Profile
        if profile_data:
            profile, _ = UserProfile.objects.get_or_create(user=instance)
            for attr, value in profile_data.items():
                setattr(profile, attr, value)
            profile.save()

        return instance

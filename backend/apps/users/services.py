from .models import User, UserProfile, UserPreference, UserStatistics

class UserService:
    """Service layer managing user profile, preferences, statistics, and permission rules."""

    @staticmethod
    def get_user_by_id(user_id):
        try:
            return User.objects.select_related('profile', 'preferences', 'statistics').get(id=user_id)
        except User.DoesNotExist:
            return None

    @staticmethod
    def get_user_by_username(username):
        try:
            return User.objects.select_related('profile', 'preferences', 'statistics').get(username__iexact=username)
        except User.DoesNotExist:
            return None

    @staticmethod
    def update_user_profile(user, data):
        profile, _ = UserProfile.objects.get_or_create(user=user)
        for field, value in data.items():
            if hasattr(profile, field) and field not in ('id', 'user', 'created_at'):
                setattr(profile, field, value)
        profile.save()
        return profile

    @staticmethod
    def update_user_preferences(user, data):
        preferences, _ = UserPreference.objects.get_or_create(user=user)
        for field, value in data.items():
            if hasattr(preferences, field) and field not in ('id', 'user', 'created_at'):
                setattr(preferences, field, value)
        preferences.save()
        return preferences

    # User Permissions Foundation
    @staticmethod
    def can_sell_coins(user) -> bool:
        """Check if user meets level and verification criteria to sell coins."""
        profile = getattr(user, 'profile', None)
        if not profile:
            return False
        return profile.level >= 5 and profile.trust_score >= 80

    @staticmethod
    def can_withdraw(user) -> bool:
        """Check if user is verified for fiat or reward withdrawals."""
        profile = getattr(user, 'profile', None)
        if not profile:
            return False
        return profile.verification_status in ('Verified', 'Trusted') and user.is_verified

    @staticmethod
    def can_access_creator_tools(user) -> bool:
        """Check if user has Creator or Business tier or is verified."""
        profile = getattr(user, 'profile', None)
        if not profile:
            return False
        return profile.subscription_tier in ('Creator', 'Business', 'Premium', 'PRO') or profile.level >= 10

    @staticmethod
    def can_access_marketplace_features(user) -> bool:
        """Check if user can browse and purchase on marketplace."""
        return user.is_active

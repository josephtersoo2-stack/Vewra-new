from .models import User, UserProfile

class UserService:
    """Service class for user queries and ecosystem profile updates."""

    @staticmethod
    def get_user_by_id(user_id):
        try:
            return User.objects.select_related('profile').get(id=user_id)
        except User.DoesNotExist:
            return None

    @staticmethod
    def update_user_profile(user, data):
        profile = getattr(user, 'profile', None)
        if not profile:
            profile = UserProfile.objects.create(user=user)

        # Update allowed profile fields
        for field, value in data.items():
            if hasattr(profile, field):
                setattr(profile, field, value)
        profile.save()
        return profile

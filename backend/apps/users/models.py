import uuid
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager
from django.db.models.signals import post_save
from django.dispatch import receiver

class UserManager(BaseUserManager):
    """Custom user manager using email as unique identifier."""

    def create_user(self, email, username, password=None, **extra_fields):
        if not email:
            raise ValueError('Email address is required')
        if not username:
            raise ValueError('Username is required')

        email = self.normalize_email(email).lower()
        username = username.strip()
        user = self.model(email=email, username=username, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, email, username, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('is_verified', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, username, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """Custom User model for VEWRA ecosystem."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True, db_index=True)
    username = models.CharField(max_length=50, unique=True, db_index=True)
    phone_number = models.CharField(max_length=25, blank=True, null=True)
    country = models.CharField(max_length=100, default='Global')
    currency = models.CharField(max_length=10, default='USD')
    timezone = models.CharField(max_length=50, default='UTC')

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_verified = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'vewra_users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.username} ({self.email})"


class UserProfile(models.Model):
    """Extended ecosystem profile data for user."""

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    display_name = models.CharField(max_length=100, blank=True, default='')
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True)
    bio = models.TextField(blank=True, default='')
    country = models.CharField(max_length=100, default='Global')
    city = models.CharField(max_length=100, blank=True, default='')
    language = models.CharField(max_length=10, default='en')
    currency = models.CharField(max_length=10, default='USD')
    timezone = models.CharField(max_length=50, default='UTC')
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=20, default='Unspecified')

    # Progression & Status
    level = models.PositiveIntegerField(default=1)
    xp = models.PositiveIntegerField(default=0)
    xp_next_level = models.PositiveIntegerField(default=1000)
    trust_score = models.PositiveIntegerField(default=75)
    verification_status = models.CharField(max_length=20, default='Basic')
    subscription_tier = models.CharField(max_length=20, default='Free')
    streak_days = models.PositiveIntegerField(default=1)
    total_coins = models.PositiveIntegerField(default=0)
    fiat_balance = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    tasks_completed = models.PositiveIntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_user_profiles'
        verbose_name = 'User Profile'
        verbose_name_plural = 'User Profiles'

    def __str__(self):
        return f"Profile: {self.display_name or self.user.username} (LVL {self.level})"


class UserPreference(models.Model):
    """User customization and application preferences."""

    THEME_CHOICES = (
        ('dark', 'Dark'),
        ('light', 'Light'),
        ('system', 'System'),
    )

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='preferences')
    theme = models.CharField(max_length=10, choices=THEME_CHOICES, default='dark')
    language = models.CharField(max_length=10, default='en')
    notification_enabled = models.BooleanField(default=True)
    email_notifications = models.BooleanField(default=True)
    push_notifications = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_user_preferences'
        verbose_name = 'User Preference'
        verbose_name_plural = 'User Preferences'

    def __str__(self):
        return f"Preferences: {self.user.username}"


class UserStatistics(models.Model):
    """Aggregated user activities and platform metrics."""

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='statistics')
    tasks_completed = models.PositiveIntegerField(default=0)
    videos_watched = models.PositiveIntegerField(default=0)
    quizzes_completed = models.PositiveIntegerField(default=0)
    comments_created = models.PositiveIntegerField(default=0)
    referrals = models.PositiveIntegerField(default=0)
    total_rewards = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_user_statistics'
        verbose_name = 'User Statistics'
        verbose_name_plural = 'User Statistics'

    def __str__(self):
        return f"Statistics: {self.user.username}"


@receiver(post_save, sender=User)
def create_or_update_user_ecosystem_entities(sender, instance, created, **kwargs):
    """Automatically create UserProfile, UserPreference, and UserStatistics upon user creation."""
    if created:
        UserProfile.objects.get_or_create(
            user=instance,
            defaults={'display_name': instance.username, 'country': instance.country, 'currency': instance.currency}
        )
        UserPreference.objects.get_or_create(user=instance)
        UserStatistics.objects.get_or_create(user=instance)
    else:
        if hasattr(instance, 'profile'):
            instance.profile.save()
        if hasattr(instance, 'preferences'):
            instance.preferences.save()
        if hasattr(instance, 'statistics'):
            instance.statistics.save()

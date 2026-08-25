from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, UserProfile, UserPreference, UserStatistics

class UserProfileInline(admin.StackedInline):
    model = UserProfile
    can_delete = False
    verbose_name_plural = 'Profile'

class UserPreferenceInline(admin.StackedInline):
    model = UserPreference
    can_delete = False
    verbose_name_plural = 'Preferences'

class UserStatisticsInline(admin.StackedInline):
    model = UserStatistics
    can_delete = False
    verbose_name_plural = 'Statistics'

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    inlines = (UserProfileInline, UserPreferenceInline, UserStatisticsInline)
    list_display = ('username', 'email', 'country', 'is_active', 'is_verified', 'is_staff')
    list_filter = ('is_active', 'is_verified', 'is_staff', 'country')
    search_fields = ('username', 'email', 'phone_number')
    ordering = ('-created_at',)
    fieldsets = (
        (None, {'fields': ('email', 'username', 'password')}),
        ('Personal Info', {'fields': ('phone_number', 'country', 'currency', 'timezone')}),
        ('Permissions', {'fields': ('is_active', 'is_verified', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important Dates', {'fields': ('last_login',)}),
    )

from django.contrib import admin
from .models import SubscriptionTier, UserSubscription

@admin.register(SubscriptionTier)
class SubscriptionTierAdmin(admin.ModelAdmin):
    list_display = ('name', 'monthly_price', 'annual_price', 'active', 'created_at')
    list_filter = ('active',)
    search_fields = ('name', 'slug', 'description')

@admin.register(UserSubscription)
class UserSubscriptionAdmin(admin.ModelAdmin):
    list_display = ('user', 'tier', 'is_active', 'auto_renew', 'expires_at', 'created_at')
    list_filter = ('is_active', 'auto_renew', 'tier')
    search_fields = ('user__username', 'user__email')

from django.db import models
from django.conf import settings

class SubscriptionTier(models.Model):
    """Membership plan definitions for the VEWRA ecosystem."""

    name = models.CharField(max_length=50, unique=True)
    slug = models.SlugField(max_length=50, unique=True)
    description = models.TextField(blank=True)
    monthly_price = models.DecimalField(max_digits=8, decimal_places=2, default=0.00)
    annual_price = models.DecimalField(max_digits=8, decimal_places=2, default=0.00)
    benefits = models.JSONField(default=list, blank=True)
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'vewra_subscription_tiers'
        verbose_name = 'Subscription Tier'
        verbose_name_plural = 'Subscription Tiers'
        ordering = ['monthly_price']

    def __str__(self):
        return f"{self.name} (${self.monthly_price}/mo)"


class UserSubscription(models.Model):
    """User active subscription and renewal state."""

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='subscription'
    )
    tier = models.ForeignKey(
        SubscriptionTier,
        on_delete=models.PROTECT,
        related_name='subscribers'
    )
    is_active = models.BooleanField(default=True)
    auto_renew = models.BooleanField(default=False)
    expires_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_user_subscriptions'
        verbose_name = 'User Subscription'
        verbose_name_plural = 'User Subscriptions'

    def __str__(self):
        return f"{self.user.username} - {self.tier.name} ({'Active' if self.is_active else 'Inactive'})"

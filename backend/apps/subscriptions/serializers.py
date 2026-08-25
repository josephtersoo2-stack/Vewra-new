from rest_framework import serializers
from .models import SubscriptionTier, UserSubscription

class SubscriptionTierSerializer(serializers.ModelSerializer):
    class Meta:
        model = SubscriptionTier
        fields = (
            'id',
            'name',
            'slug',
            'description',
            'monthly_price',
            'annual_price',
            'benefits',
            'active',
            'created_at',
        )


class UserSubscriptionSerializer(serializers.ModelSerializer):
    tier = SubscriptionTierSerializer(read_only=True)

    class Meta:
        model = UserSubscription
        fields = (
            'id',
            'tier',
            'is_active',
            'auto_renew',
            'expires_at',
            'created_at',
            'updated_at',
        )

from decimal import Decimal
from rest_framework import serializers
from apps.advertising.billing.models import (
    AdvertiserWallet,
    CampaignBudget,
    AdvertisementCharge,
    AdvertisementFraudLog,
    BudgetStatus,
    ChargeEventType,
)


class AdvertiserWalletSerializer(serializers.ModelSerializer):
    advertiser_email = serializers.EmailField(source="advertiser.email", read_only=True)

    class Meta:
        model = AdvertiserWallet
        fields = [
            "id",
            "advertiser",
            "advertiser_email",
            "balance",
            "currency",
            "total_spent",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "advertiser", "total_spent", "created_at", "updated_at"]


class WalletFundingSerializer(serializers.Serializer):
    amount = serializers.DecimalField(max_digits=12, decimal_places=2, min_value=Decimal("1.00"))
    currency = serializers.CharField(max_length=10, default="USD")


class CampaignBudgetSerializer(serializers.ModelSerializer):
    campaign_title = serializers.CharField(source="campaign.title", read_only=True)
    remaining_budget = serializers.DecimalField(max_digits=12, decimal_places=4, read_only=True)
    percentage_used = serializers.FloatField(read_only=True)

    class Meta:
        model = CampaignBudget
        fields = [
            "id",
            "campaign",
            "campaign_title",
            "daily_budget",
            "total_budget",
            "spent_amount",
            "daily_spent_amount",
            "remaining_budget",
            "percentage_used",
            "cpm_rate",
            "cpc_rate",
            "cpv_rate",
            "start_date",
            "end_date",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "campaign", "spent_amount", "daily_spent_amount", "created_at", "updated_at"]


class CampaignBudgetConfigureSerializer(serializers.Serializer):
    daily_budget = serializers.DecimalField(max_digits=12, decimal_places=2, min_value=Decimal("0.00"), required=False)
    total_budget = serializers.DecimalField(max_digits=12, decimal_places=2, min_value=Decimal("0.00"), required=False)
    cpm_rate = serializers.DecimalField(max_digits=8, decimal_places=2, min_value=Decimal("0.10"), required=False)
    cpc_rate = serializers.DecimalField(max_digits=8, decimal_places=2, min_value=Decimal("0.01"), required=False)
    cpv_rate = serializers.DecimalField(max_digits=8, decimal_places=2, min_value=Decimal("0.01"), required=False)
    start_date = serializers.DateTimeField(required=False, allow_null=True)
    end_date = serializers.DateTimeField(required=False, allow_null=True)
    status = serializers.ChoiceField(choices=BudgetStatus.choices, required=False)


class AdvertisementChargeSerializer(serializers.ModelSerializer):
    campaign_title = serializers.CharField(source="campaign.title", read_only=True)
    advertiser_email = serializers.EmailField(source="advertiser.email", read_only=True)

    class Meta:
        model = AdvertisementCharge
        fields = [
            "id",
            "advertiser",
            "advertiser_email",
            "campaign",
            "campaign_title",
            "event_type",
            "amount",
            "reference_id",
            "fraud_score",
            "created_at",
        ]
        read_only_fields = fields


class AdvertisementFraudLogSerializer(serializers.ModelSerializer):
    campaign_title = serializers.CharField(source="campaign.title", read_only=True)

    class Meta:
        model = AdvertisementFraudLog
        fields = [
            "id",
            "advertiser",
            "campaign",
            "campaign_title",
            "event_type",
            "fraud_score",
            "risk_level",
            "flag_reason",
            "session_id",
            "is_blocked",
            "created_at",
        ]
        read_only_fields = fields

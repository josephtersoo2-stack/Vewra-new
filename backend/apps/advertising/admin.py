from django.contrib import admin
from apps.advertising.billing.models import (
    AdvertiserWallet,
    CampaignBudget,
    AdvertisementCharge,
    AdvertisementFraudLog,
)


@admin.register(AdvertiserWallet)
class AdvertiserWalletAdmin(admin.ModelAdmin):
    list_display = ("id", "advertiser", "balance", "currency", "total_spent", "updated_at")
    search_fields = ("advertiser__email", "advertiser__username")
    readonly_fields = ("id", "created_at", "updated_at")


@admin.register(CampaignBudget)
class CampaignBudgetAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "campaign",
        "total_budget",
        "spent_amount",
        "daily_budget",
        "daily_spent_amount",
        "status",
        "cpm_rate",
        "cpc_rate",
        "cpv_rate",
    )
    list_filter = ("status", "created_at")
    search_fields = ("campaign__title", "campaign__owner__email")
    readonly_fields = ("id", "spent_amount", "daily_spent_amount", "created_at", "updated_at")


@admin.register(AdvertisementCharge)
class AdvertisementChargeAdmin(admin.ModelAdmin):
    list_display = ("id", "campaign", "advertiser", "event_type", "amount", "fraud_score", "created_at")
    list_filter = ("event_type", "created_at")
    search_fields = ("campaign__title", "advertiser__email", "reference_id")
    readonly_fields = ("id", "advertiser", "campaign", "event_type", "amount", "reference_id", "fraud_score", "created_at")
    date_hierarchy = "created_at"


@admin.register(AdvertisementFraudLog)
class AdvertisementFraudLogAdmin(admin.ModelAdmin):
    list_display = ("id", "campaign", "event_type", "risk_level", "fraud_score", "flag_reason", "is_blocked", "created_at")
    list_filter = ("risk_level", "is_blocked", "event_type", "created_at")
    search_fields = ("campaign__title", "session_id", "ip_hash", "device_id", "flag_reason")
    readonly_fields = ("id", "advertiser", "campaign", "event_type", "fraud_score", "risk_level", "flag_reason", "ip_hash", "session_id", "device_id", "is_blocked", "created_at")
    date_hierarchy = "created_at"

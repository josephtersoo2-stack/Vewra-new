import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings
from apps.campaigns.models import Campaign


class BudgetStatus(models.TextChoices):
    ACTIVE = "ACTIVE", "Active"
    PAUSED = "PAUSED", "Paused"
    EXHAUSTED = "EXHAUSTED", "Budget Exhausted"
    EXPIRED = "EXPIRED", "Expired"
    CANCELLED = "CANCELLED", "Cancelled"


class ChargeEventType(models.TextChoices):
    IMPRESSION = "IMPRESSION", "Impression (CPM)"
    CLICK = "CLICK", "Click (CPC)"
    VIDEO_COMPLETION = "VIDEO_COMPLETION", "Video Completion (CPV)"
    CONVERSION = "CONVERSION", "Conversion Action"


class FraudRiskLevel(models.TextChoices):
    LOW = "LOW", "Low Risk"
    MEDIUM = "MEDIUM", "Medium Risk"
    HIGH = "HIGH", "High Risk / Blocked"


class AdvertiserWallet(models.Model):
    """
    Financial balance and spending ledger for an advertiser account.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    advertiser = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="advertiser_wallet",
    )
    balance = models.DecimalField(max_digits=14, decimal_places=4, default=Decimal("0.0000"))
    currency = models.CharField(max_length=10, default="USD")
    total_spent = models.DecimalField(max_digits=14, decimal_places=4, default=Decimal("0.0000"))
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "advertising_advertiser_wallets"
        verbose_name = "Advertiser Wallet"
        verbose_name_plural = "Advertiser Wallets"
        indexes = [
            models.Index(fields=["advertiser", "created_at"]),
        ]

    def __str__(self):
        return f"Wallet ({self.advertiser.email}): ${self.balance:.2f} {self.currency}"

    def deposit(self, amount: Decimal) -> Decimal:
        if amount <= Decimal("0.00"):
            raise ValueError("Deposit amount must be strictly positive.")
        self.balance += Decimal(str(amount))
        self.save(update_fields=["balance", "updated_at"])
        return self.balance

    def deduct(self, amount: Decimal) -> bool:
        amount_dec = Decimal(str(amount))
        if amount_dec <= Decimal("0.00"):
            return False
        if self.balance < amount_dec:
            return False
        self.balance -= amount_dec
        self.total_spent += amount_dec
        self.save(update_fields=["balance", "total_spent", "updated_at"])
        return True


class CampaignBudget(models.Model):
    """
    Monetary budget constraints, daily caps, and rate schedules for a campaign.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    campaign = models.OneToOneField(
        Campaign,
        on_delete=models.CASCADE,
        related_name="budget_config",
    )
    daily_budget = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal("0.00"))
    total_budget = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal("0.00"))
    spent_amount = models.DecimalField(max_digits=14, decimal_places=4, default=Decimal("0.0000"))
    daily_spent_amount = models.DecimalField(max_digits=14, decimal_places=4, default=Decimal("0.0000"))
    last_spend_date = models.DateField(null=True, blank=True)

    # Pricing Rates
    cpm_rate = models.DecimalField(
        max_digits=8, decimal_places=2, default=Decimal("2.00"), help_text="Cost per 1000 impressions in USD"
    )
    cpc_rate = models.DecimalField(
        max_digits=8, decimal_places=2, default=Decimal("0.10"), help_text="Cost per verified click in USD"
    )
    cpv_rate = models.DecimalField(
        max_digits=8, decimal_places=2, default=Decimal("0.05"), help_text="Cost per video completion (>=95%) in USD"
    )

    start_date = models.DateTimeField(null=True, blank=True)
    end_date = models.DateTimeField(null=True, blank=True)
    status = models.CharField(
        max_length=20,
        choices=BudgetStatus.choices,
        default=BudgetStatus.ACTIVE,
        db_index=True,
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "advertising_campaign_budgets"
        verbose_name = "Campaign Budget"
        verbose_name_plural = "Campaign Budgets"
        indexes = [
            models.Index(fields=["campaign", "status"]),
            models.Index(fields=["status", "created_at"]),
        ]

    def __str__(self):
        return f"Budget ({self.campaign.title}): ${self.spent_amount:.2f}/${self.total_budget:.2f} [{self.status}]"

    @property
    def remaining_budget(self) -> Decimal:
        if self.total_budget <= Decimal("0.00"):
            return Decimal("0.00")
        remaining = self.total_budget - Decimal(str(self.spent_amount))
        return max(Decimal("0.00"), remaining)

    @property
    def percentage_used(self) -> float:
        if self.total_budget <= Decimal("0.00"):
            return 0.0
        return min(100.0, float((Decimal(str(self.spent_amount)) / self.total_budget) * Decimal("100.0")))


class AdvertisementCharge(models.Model):
    """
    Ledger record for each billable advertisement engagement event.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    advertiser = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="advertiser_charges",
    )
    campaign = models.ForeignKey(
        Campaign,
        on_delete=models.CASCADE,
        related_name="advertiser_charges",
    )
    event_type = models.CharField(
        max_length=30,
        choices=ChargeEventType.choices,
        db_index=True,
    )
    amount = models.DecimalField(max_digits=12, decimal_places=4)
    reference_id = models.CharField(
        max_length=255, db_index=True, help_text="ID of the tracked impression, click, or engagement"
    )
    fraud_score = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table = "advertising_charges"
        verbose_name = "Advertisement Charge"
        verbose_name_plural = "Advertisement Charges"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["advertiser", "created_at"]),
            models.Index(fields=["campaign", "created_at"]),
            models.Index(fields=["event_type", "created_at"]),
            models.Index(fields=["reference_id"]),
        ]

    def __str__(self):
        return f"Charge ({self.event_type}): ${self.amount:.4f} - {self.campaign.title}"


class AdvertisementFraudLog(models.Model):
    """
    Audit log for suspicious advertisement clicks, invalid views, or automated abuse attempts.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    advertiser = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="advertising_fraud_logs",
    )
    campaign = models.ForeignKey(
        Campaign,
        on_delete=models.CASCADE,
        related_name="fraud_logs",
    )
    event_type = models.CharField(
        max_length=30,
        choices=ChargeEventType.choices,
    )
    fraud_score = models.IntegerField(default=0)
    risk_level = models.CharField(
        max_length=20,
        choices=FraudRiskLevel.choices,
        default=FraudRiskLevel.LOW,
        db_index=True,
    )
    flag_reason = models.CharField(max_length=255)
    ip_hash = models.CharField(max_length=64, blank=True, default="")
    session_id = models.CharField(max_length=128, blank=True, default="")
    device_id = models.CharField(max_length=128, blank=True, default="")
    is_blocked = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table = "advertising_fraud_logs"
        verbose_name = "Fraud Log"
        verbose_name_plural = "Fraud Logs"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["campaign", "risk_level"]),
            models.Index(fields=["risk_level", "created_at"]),
            models.Index(fields=["ip_hash", "created_at"]),
            models.Index(fields=["session_id", "created_at"]),
        ]

    def __str__(self):
        return f"FraudLog ({self.risk_level} - Score {self.fraud_score}): {self.flag_reason}"

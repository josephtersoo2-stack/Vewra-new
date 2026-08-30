import csv
import io
from decimal import Decimal
from datetime import date
from django.db import transaction
from django.utils import timezone
from django.core.exceptions import ValidationError, PermissionDenied
from django.db.models import Sum, Count, Avg

from apps.campaigns.models import Campaign, CampaignStatus
from apps.advertising.billing.models import (
    AdvertiserWallet,
    CampaignBudget,
    AdvertisementCharge,
    BudgetStatus,
    ChargeEventType,
)
from apps.advertising.billing.fraud import FraudScoreService


class AdvertiserBillingService:
    """
    Core engine for advertiser balances, dynamic unit pricing, campaign budget protection,
    monetisation charge processing, and financial reporting.
    """

    @classmethod
    def get_or_create_wallet(cls, user) -> AdvertiserWallet:
        if not user or not user.is_authenticated:
            raise ValidationError("Valid authenticated user required for advertiser wallet.")
        wallet, _ = AdvertiserWallet.objects.get_or_create(
            advertiser=user,
            defaults={
                "balance": Decimal("0.0000"),
                "currency": "USD",
                "total_spent": Decimal("0.0000"),
            },
        )
        return wallet

    @classmethod
    @transaction.atomic
    def fund_wallet(cls, user, amount: Decimal, currency: str = "USD") -> AdvertiserWallet:
        amount_dec = Decimal(str(amount))
        if amount_dec <= Decimal("0.00"):
            raise ValidationError("Funding amount must be greater than zero.")
        wallet = AdvertiserWallet.objects.select_for_update().get_or_create(
            advertiser=user,
            defaults={"balance": Decimal("0.0000"), "currency": currency, "total_spent": Decimal("0.0000")},
        )[0]
        wallet.deposit(amount_dec)
        return wallet

    @classmethod
    def get_or_create_budget(
        cls,
        campaign: Campaign,
        daily_budget: Decimal = Decimal("0.00"),
        total_budget: Decimal = Decimal("0.00"),
        cpm_rate: Decimal = Decimal("2.00"),
        cpc_rate: Decimal = Decimal("0.10"),
        cpv_rate: Decimal = Decimal("0.05"),
        start_date=None,
        end_date=None,
    ) -> CampaignBudget:
        # If campaign has an existing budget, sync total_budget with campaign.budget if needed
        default_total = Decimal(str(campaign.budget)) if campaign.budget > 0 else total_budget
        budget, created = CampaignBudget.objects.get_or_create(
            campaign=campaign,
            defaults={
                "daily_budget": Decimal(str(daily_budget)),
                "total_budget": Decimal(str(default_total)),
                "cpm_rate": Decimal(str(cpm_rate)),
                "cpc_rate": Decimal(str(cpc_rate)),
                "cpv_rate": Decimal(str(cpv_rate)),
                "start_date": start_date or campaign.start_date,
                "end_date": end_date or campaign.end_date,
                "status": BudgetStatus.ACTIVE,
            },
        )
        return budget

    @classmethod
    def calculate_impression_cost(cls, budget: CampaignBudget) -> Decimal:
        """
        Calculates cost for 1 impression based on CPM (Cost Per 1,000 Impressions).
        E.g. $2.00 CPM / 1000 = $0.0020 per impression.
        """
        return Decimal(str(budget.cpm_rate)) / Decimal("1000.0")

    @classmethod
    def calculate_click_cost(cls, budget: CampaignBudget) -> Decimal:
        """
        Calculates cost for 1 verified user click (CPC).
        """
        return Decimal(str(budget.cpc_rate))

    @classmethod
    def calculate_video_completion_cost(cls, budget: CampaignBudget, completion_percentage: float) -> Decimal:
        """
        Billed only when video completion >= 95%.
        """
        if completion_percentage >= 95.0:
            return Decimal(str(budget.cpv_rate))
        return Decimal("0.0000")

    @classmethod
    def validate_campaign_delivery_eligibility(cls, campaign_id) -> tuple[bool, str]:
        """
        Comprehensive budget protection check before an ad can be served or delivered.
        Verifies:
        1. Campaign is active
        2. Advertiser wallet has funds
        3. Campaign budget limit not reached
        4. Daily budget cap not exceeded
        5. Start & end dates are valid
        """
        try:
            campaign = Campaign.objects.select_related("owner").get(id=campaign_id)
        except Campaign.DoesNotExist:
            return False, "Campaign does not exist."

        if campaign.status != CampaignStatus.ACTIVE:
            return False, f"Campaign is not active (status: {campaign.status})."

        # Check dates
        now = timezone.now()
        if campaign.start_date and now < campaign.start_date:
            return False, "Campaign delivery has not started yet."
        if campaign.end_date and now > campaign.end_date:
            return False, "Campaign delivery schedule has expired."

        # Check advertiser wallet
        wallet = AdvertiserWallet.objects.filter(advertiser=campaign.owner).first()
        if not wallet or wallet.balance <= Decimal("0.00"):
            return False, "Advertiser wallet has zero or insufficient balance."

        # Check campaign budget
        budget = CampaignBudget.objects.filter(campaign=campaign).first()
        if budget:
            if budget.status in (BudgetStatus.EXHAUSTED, BudgetStatus.PAUSED, BudgetStatus.CANCELLED):
                return False, f"Campaign budget status is {budget.status}."

            if budget.total_budget > Decimal("0.00") and budget.remaining_budget <= Decimal("0.00"):
                if budget.status != BudgetStatus.EXHAUSTED:
                    budget.status = BudgetStatus.EXHAUSTED
                    budget.save(update_fields=["status", "updated_at"])
                return False, "Campaign total budget has been exhausted."

            # Daily cap check
            today = date.today()
            if budget.last_spend_date == today and budget.daily_budget > Decimal("0.00"):
                if budget.daily_spent_amount >= budget.daily_budget:
                    return False, "Campaign daily budget cap has been reached for today."

        return True, "Eligible for advertisement delivery."

    @classmethod
    @transaction.atomic
    def process_advertisement_charge(
        cls,
        campaign_id,
        event_type: str,
        reference_id: str,
        session_id: str = "",
        ip_address: str = "",
        device_id: str = "",
        user=None,
        watched_seconds: float = 0.0,
        video_duration: float = 0.0,
        completion_percentage: float = 0.0,
    ) -> dict:
        """
        Automatic Charge Processing:
        1. Identifies campaign and advertiser
        2. Evaluates anti-fraud risk score
        3. Calculates dynamic unit cost
        4. Validates wallet and budget limits
        5. Deducts amount atomically from wallet
        6. Creates AdvertisementCharge record
        7. Updates campaign and daily spend
        """
        try:
            campaign = Campaign.objects.select_for_update().select_related("owner").get(id=campaign_id)
        except Campaign.DoesNotExist:
            return {"charged": False, "reason": "Campaign does not exist."}

        advertiser = campaign.owner
        wallet = AdvertiserWallet.objects.select_for_update().get_or_create(
            advertiser=advertiser,
            defaults={"balance": Decimal("0.0000"), "currency": "USD", "total_spent": Decimal("0.0000")},
        )[0]
        budget = CampaignBudget.objects.select_for_update().get_or_create(
            campaign=campaign,
            defaults={
                "daily_budget": Decimal("0.00"),
                "total_budget": Decimal(str(campaign.budget)) if campaign.budget > 0 else Decimal("0.00"),
                "status": BudgetStatus.ACTIVE,
            },
        )[0]

        # 1. Anti-fraud evaluation
        fraud_result = FraudScoreService.evaluate_engagement(
            campaign=campaign,
            event_type=event_type,
            session_id=session_id,
            ip_address=ip_address,
            device_id=device_id,
            user=user,
            watched_seconds=watched_seconds,
            video_duration=video_duration,
        )

        if fraud_result["is_blocked"]:
            return {
                "charged": False,
                "blocked": True,
                "fraud_score": fraud_result["fraud_score"],
                "reason": f"Blocked by anti-fraud filter: {fraud_result['flag_reason']}",
            }

        # 2. Calculate cost
        cost = Decimal("0.0000")
        if event_type == ChargeEventType.IMPRESSION:
            cost = cls.calculate_impression_cost(budget)
        elif event_type == ChargeEventType.CLICK:
            cost = cls.calculate_click_cost(budget)
        elif event_type == ChargeEventType.VIDEO_COMPLETION:
            cost = cls.calculate_video_completion_cost(budget, completion_percentage)
        elif event_type == ChargeEventType.CONVERSION:
            cost = Decimal("0.2500")  # Conversion action standard

        if cost <= Decimal("0.0000"):
            return {"charged": False, "amount": Decimal("0.0000"), "reason": "Non-billable event."}

        # 3. Check wallet balance & budget protection
        if wallet.balance < cost:
            budget.status = BudgetStatus.EXHAUSTED
            budget.save(update_fields=["status", "updated_at"])
            return {
                "charged": False,
                "reason": "Advertiser wallet has insufficient balance. Campaign budget paused.",
            }

        if budget.total_budget > Decimal("0.00") and budget.remaining_budget < cost:
            budget.status = BudgetStatus.EXHAUSTED
            budget.save(update_fields=["status", "updated_at"])
            return {
                "charged": False,
                "reason": "Campaign total budget exhausted.",
            }

        # Daily budget reset check
        today = date.today()
        if budget.last_spend_date != today:
            budget.daily_spent_amount = Decimal("0.0000")
            budget.last_spend_date = today

        if budget.daily_budget > Decimal("0.00") and (budget.daily_spent_amount + cost) > budget.daily_budget:
            return {
                "charged": False,
                "reason": "Campaign daily spending cap reached for today.",
            }

        # 4. Atomic deduction & record creation
        wallet.deduct(cost)

        budget.spent_amount += cost
        budget.daily_spent_amount += cost
        budget.save(update_fields=["spent_amount", "daily_spent_amount", "last_spend_date", "updated_at"])

        charge = AdvertisementCharge.objects.create(
            advertiser=advertiser,
            campaign=campaign,
            event_type=event_type,
            amount=cost,
            reference_id=reference_id,
            fraud_score=fraud_result["fraud_score"],
        )

        return {
            "charged": True,
            "charge_id": str(charge.id),
            "event_type": event_type,
            "amount": cost,
            "wallet_balance": wallet.balance,
            "remaining_budget": budget.remaining_budget,
            "fraud_score": fraud_result["fraud_score"],
        }

    @classmethod
    def generate_spending_summary(cls, campaign_id, user=None) -> dict:
        """
        Fetches monetary spending controls, budget usage, and unit pricing for a campaign.
        """
        campaign = Campaign.objects.select_related("owner").get(id=campaign_id)

        # Permissions check: Only campaign owner or staff/admin can view spending
        if user:
            is_owner = str(campaign.owner_id) == str(user.id)
            is_admin = user.is_staff or getattr(user, "is_superuser", False) or str(getattr(user, "role", "")).lower() == "admin"
            if not (is_owner or is_admin):
                raise PermissionDenied("You do not have permission to view spending for this campaign.")

        budget = cls.get_or_create_budget(campaign)

        return {
            "campaign_id": str(campaign.id),
            "campaign_title": campaign.title,
            "status": budget.status,
            "total_budget": float(budget.total_budget),
            "spent_amount": float(budget.spent_amount),
            "remaining_budget": float(budget.remaining_budget),
            "percentage_used": round(budget.percentage_used, 2),
            "daily_budget": float(budget.daily_budget),
            "daily_spent_amount": float(budget.daily_spent_amount),
            "cpm_rate": float(budget.cpm_rate),
            "cpc_rate": float(budget.cpc_rate),
            "cpv_rate": float(budget.cpv_rate),
            "start_date": budget.start_date.isoformat() if budget.start_date else None,
            "end_date": budget.end_date.isoformat() if budget.end_date else None,
        }

    @classmethod
    def generate_financial_report(cls, user, campaign_id=None, start_date=None, end_date=None) -> dict:
        """
        Aggregates comprehensive financial performance metrics, unit pricing,
        and attribution ROI across all campaigns or for a specific campaign.
        """
        is_admin = user.is_staff or getattr(user, "is_superuser", False) or str(getattr(user, "role", "")).lower() == "admin"

        charges_qs = AdvertisementCharge.objects.all() if is_admin else AdvertisementCharge.objects.filter(advertiser=user)
        campaigns_qs = Campaign.objects.all() if is_admin else Campaign.objects.filter(owner=user)

        if campaign_id:
            charges_qs = charges_qs.filter(campaign_id=campaign_id)
            campaigns_qs = campaigns_qs.filter(id=campaign_id)

        if start_date:
            charges_qs = charges_qs.filter(created_at__gte=start_date)
        if end_date:
            charges_qs = charges_qs.filter(created_at__lte=end_date)

        total_spent = charges_qs.aggregate(total=Sum("amount"))["total"] or Decimal("0.0000")
        total_charges_count = charges_qs.count()

        # Group by campaign
        campaign_reports = []
        for camp in campaigns_qs:
            camp_charges = charges_qs.filter(campaign=camp)
            camp_spent = camp_charges.aggregate(total=Sum("amount"))["total"] or Decimal("0.0000")
            imp_count = camp_charges.filter(event_type=ChargeEventType.IMPRESSION).count()
            click_count = camp_charges.filter(event_type=ChargeEventType.CLICK).count()
            video_comp_count = camp_charges.filter(event_type=ChargeEventType.VIDEO_COMPLETION).count()

            budget = CampaignBudget.objects.filter(campaign=camp).first()
            tot_budget = budget.total_budget if budget else Decimal("0.00")
            rem_budget = budget.remaining_budget if budget else Decimal("0.00")

            ctr = round((click_count / imp_count * 100), 2) if imp_count > 0 else 0.0
            video_rate = round((video_comp_count / imp_count * 100), 2) if imp_count > 0 else 0.0

            # Performance Rating: A (High CTR >= 3%), B (Good CTR >= 1.5%), C (Normal)
            perf_score = "A" if ctr >= 3.0 else ("B" if ctr >= 1.5 else "C")

            campaign_reports.append({
                "campaign_id": str(camp.id),
                "campaign_name": camp.title,
                "status": camp.status,
                "impressions": imp_count,
                "clicks": click_count,
                "ctr": ctr,
                "video_completions": video_comp_count,
                "video_completion_rate": video_rate,
                "amount_spent": float(camp_spent),
                "total_budget": float(tot_budget),
                "remaining_budget": float(rem_budget),
                "performance_score": perf_score,
            })

        wallet = cls.get_or_create_wallet(user)

        return {
            "advertiser": user.email,
            "wallet_balance": float(wallet.balance),
            "wallet_currency": wallet.currency,
            "total_spent_lifetime": float(wallet.total_spent),
            "filtered_spent": float(total_spent),
            "total_charges_count": total_charges_count,
            "campaigns_count": len(campaign_reports),
            "campaigns": campaign_reports,
        }

    @classmethod
    def export_report_csv(cls, user, campaign_id=None) -> str:
        """
        Generates CSV-formatted financial and performance export.
        """
        report_data = cls.generate_financial_report(user, campaign_id=campaign_id)
        output = io.StringIO()
        writer = csv.writer(output)

        writer.writerow([
            "Campaign Name",
            "Status",
            "Total Impressions",
            "Total Clicks",
            "CTR (%)",
            "Video Completions",
            "Completion Rate (%)",
            "Amount Spent ($)",
            "Total Budget ($)",
            "Remaining Budget ($)",
            "Performance Score",
        ])

        for c in report_data["campaigns"]:
            writer.writerow([
                c["campaign_name"],
                c["status"],
                c["impressions"],
                c["clicks"],
                c["ctr"],
                c["video_completions"],
                c["video_completion_rate"],
                c["amount_spent"],
                c["total_budget"],
                c["remaining_budget"],
                c["performance_score"],
            ])

        return output.getvalue()

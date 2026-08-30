from decimal import Decimal
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.exceptions import PermissionDenied

from apps.campaigns.models import Campaign, CampaignType, CampaignStatus
from apps.advertising.billing.models import (
    AdvertiserWallet,
    CampaignBudget,
    AdvertisementCharge,
    BudgetStatus,
    ChargeEventType,
)
from apps.advertising.billing.services import AdvertiserBillingService

User = get_user_model()


class AdvertiserBillingServiceTests(TestCase):
    def setUp(self):
        self.advertiser = User.objects.create_user(
            username="service_advertiser",
            email="service_adv@example.com",
            password="StrongPassword123!",
        )
        self.advertiser.role = "advertiser"
        self.advertiser.is_advertiser = True

        self.wallet = AdvertiserBillingService.fund_wallet(self.advertiser, Decimal("100.00"))

        self.campaign = Campaign.objects.create(
            owner=self.advertiser,
            title="Premium Product Launch",
            campaign_type=CampaignType.ADVERTISEMENT,
            budget=Decimal("50.00"),
            status=CampaignStatus.ACTIVE,
        )
        self.budget = AdvertiserBillingService.get_or_create_budget(
            campaign=self.campaign,
            daily_budget=Decimal("20.00"),
            total_budget=Decimal("50.00"),
            cpm_rate=Decimal("2.00"),  # $0.002 per impression
            cpc_rate=Decimal("0.10"),  # $0.10 per click
            cpv_rate=Decimal("0.05"),  # $0.05 per video completion
        )

    def test_unit_cost_calculations(self):
        # 1 impression = $2.00 / 1000 = $0.002
        imp_cost = AdvertiserBillingService.calculate_impression_cost(self.budget)
        self.assertEqual(imp_cost, Decimal("0.002"))

        # 1 click = $0.10
        click_cost = AdvertiserBillingService.calculate_click_cost(self.budget)
        self.assertEqual(click_cost, Decimal("0.10"))

        # Video completion < 95% = $0.00
        cpv_incomplete = AdvertiserBillingService.calculate_video_completion_cost(self.budget, 80.0)
        self.assertEqual(cpv_incomplete, Decimal("0.0000"))

        # Video completion >= 95% = $0.05
        cpv_complete = AdvertiserBillingService.calculate_video_completion_cost(self.budget, 96.5)
        self.assertEqual(cpv_complete, Decimal("0.05"))

    def test_delivery_eligibility_validation(self):
        # Initial state: Eligible
        eligible, reason = AdvertiserBillingService.validate_campaign_delivery_eligibility(self.campaign.id)
        self.assertTrue(eligible)

        # Inactive campaign: Ineligible
        self.campaign.status = CampaignStatus.PAUSED
        self.campaign.save()
        eligible, reason = AdvertiserBillingService.validate_campaign_delivery_eligibility(self.campaign.id)
        self.assertFalse(eligible)
        self.assertIn("not active", reason)

        # Restore campaign active
        self.campaign.status = CampaignStatus.ACTIVE
        self.campaign.save()

        # Zero wallet balance: Ineligible
        self.wallet.balance = Decimal("0.0000")
        self.wallet.save()
        eligible, reason = AdvertiserBillingService.validate_campaign_delivery_eligibility(self.campaign.id)
        self.assertFalse(eligible)
        self.assertIn("insufficient balance", reason)

    def test_process_advertisement_charge_impression(self):
        result = AdvertiserBillingService.process_advertisement_charge(
            campaign_id=self.campaign.id,
            event_type=ChargeEventType.IMPRESSION,
            reference_id="imp-test-100",
            session_id="session-user-1",
        )

        self.assertTrue(result["charged"])
        self.assertEqual(result["amount"], Decimal("0.002"))
        self.assertEqual(AdvertisementCharge.objects.count(), 1)

        self.wallet.refresh_from_db()
        self.assertEqual(self.wallet.balance, Decimal("99.9980"))
        self.assertEqual(self.wallet.total_spent, Decimal("0.0020"))

        self.budget.refresh_from_db()
        self.assertEqual(self.budget.spent_amount, Decimal("0.0020"))

    def test_process_advertisement_charge_click(self):
        result = AdvertiserBillingService.process_advertisement_charge(
            campaign_id=self.campaign.id,
            event_type=ChargeEventType.CLICK,
            reference_id="click-test-200",
            session_id="session-user-2",
        )

        self.assertTrue(result["charged"])
        self.assertEqual(result["amount"], Decimal("0.10"))

        self.wallet.refresh_from_db()
        self.assertEqual(self.wallet.balance, Decimal("99.9000"))

    def test_process_advertisement_charge_video_completion(self):
        result = AdvertiserBillingService.process_advertisement_charge(
            campaign_id=self.campaign.id,
            event_type=ChargeEventType.VIDEO_COMPLETION,
            reference_id="video-eng-300",
            session_id="session-user-3",
            watched_seconds=29.0,
            video_duration=30.0,
            completion_percentage=96.6,
        )

        self.assertTrue(result["charged"])
        self.assertEqual(result["amount"], Decimal("0.05"))

    def test_overspending_prevention(self):
        # Set budget to $0.05
        self.budget.total_budget = Decimal("0.05")
        self.budget.save()

        # Click costs $0.10 which exceeds $0.05 remaining budget
        result = AdvertiserBillingService.process_advertisement_charge(
            campaign_id=self.campaign.id,
            event_type=ChargeEventType.CLICK,
            reference_id="click-exceeds-budget",
            session_id="session-user-4",
        )

        self.assertFalse(result["charged"])
        self.assertIn("exhausted", result["reason"])

    def test_financial_report_and_csv_export(self):
        # Record 1 impression & 1 click
        AdvertiserBillingService.process_advertisement_charge(
            campaign_id=self.campaign.id,
            event_type=ChargeEventType.IMPRESSION,
            reference_id="imp-rep-1",
        )
        AdvertiserBillingService.process_advertisement_charge(
            campaign_id=self.campaign.id,
            event_type=ChargeEventType.CLICK,
            reference_id="click-rep-1",
        )

        report = AdvertiserBillingService.generate_financial_report(self.advertiser)
        self.assertEqual(report["total_charges_count"], 2)
        self.assertTrue(report["filtered_spent"] > 0)
        self.assertEqual(len(report["campaigns"]), 1)

        csv_output = AdvertiserBillingService.export_report_csv(self.advertiser)
        self.assertIn("Campaign Name", csv_output)
        self.assertIn("Premium Product Launch", csv_output)

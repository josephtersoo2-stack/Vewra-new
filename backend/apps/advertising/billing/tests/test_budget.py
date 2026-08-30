import uuid
from decimal import Decimal
from django.test import TestCase
from django.contrib.auth import get_user_model

from apps.campaigns.models import Campaign, CampaignType, CampaignStatus
from apps.advertising.billing.models import CampaignBudget, BudgetStatus
from apps.advertising.billing.services import AdvertiserBillingService

User = get_user_model()


class CampaignBudgetTests(TestCase):
    def setUp(self):
        self.advertiser = User.objects.create_user(
            username="budget_advertiser",
            email="budget_adv@example.com",
            password="StrongPassword123!",
        )
        self.advertiser.role = "advertiser"
        self.advertiser.is_advertiser = True

        self.campaign = Campaign.objects.create(
            owner=self.advertiser,
            title="Summer Brand Blitz",
            campaign_type=CampaignType.ADVERTISEMENT,
            budget=Decimal("500.00"),
            status=CampaignStatus.ACTIVE,
        )

    def test_budget_creation_and_rates(self):
        budget = AdvertiserBillingService.get_or_create_budget(
            campaign=self.campaign,
            daily_budget=Decimal("50.00"),
            total_budget=Decimal("500.00"),
            cpm_rate=Decimal("2.50"),
            cpc_rate=Decimal("0.15"),
            cpv_rate=Decimal("0.08"),
        )

        self.assertIsInstance(budget.id, uuid.UUID)
        self.assertEqual(budget.campaign, self.campaign)
        self.assertEqual(budget.total_budget, Decimal("500.00"))
        self.assertEqual(budget.daily_budget, Decimal("50.00"))
        self.assertEqual(budget.spent_amount, Decimal("0.0000"))
        self.assertEqual(budget.remaining_budget, Decimal("500.00"))
        self.assertEqual(budget.percentage_used, 0.0)
        self.assertEqual(budget.status, BudgetStatus.ACTIVE)

    def test_remaining_budget_and_percentage_calculation(self):
        budget = AdvertiserBillingService.get_or_create_budget(
            campaign=self.campaign,
        )
        budget.total_budget = Decimal("200.00")
        budget.spent_amount = Decimal("50.00")
        budget.save()

        self.assertEqual(budget.remaining_budget, Decimal("150.00"))
        self.assertEqual(budget.percentage_used, 25.0)

    def test_zero_budget_graceful_handling(self):
        campaign_zero = Campaign.objects.create(
            owner=self.advertiser,
            title="Zero Budget Campaign",
            campaign_type=CampaignType.ADVERTISEMENT,
            budget=Decimal("0.00"),
            status=CampaignStatus.DRAFT,
        )
        budget = AdvertiserBillingService.get_or_create_budget(campaign=campaign_zero)
        self.assertEqual(budget.remaining_budget, Decimal("0.00"))
        self.assertEqual(budget.percentage_used, 0.0)

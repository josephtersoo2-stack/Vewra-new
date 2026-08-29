import uuid
from decimal import Decimal
from django.test import TestCase
from django.contrib.auth import get_user_model
from apps.campaigns.models import Campaign, CampaignType, CampaignStatus

User = get_user_model()


class CampaignModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="advertiser@example.com",
            username="advertiser1",
            password="Password123!",
        )

    def test_create_campaign_defaults(self):
        campaign = Campaign.objects.create(
            owner=self.user,
            title="Summer Video Campaign",
            campaign_type=CampaignType.TASK,
            budget=Decimal("500.00"),
        )
        self.assertIsInstance(campaign.id, uuid.UUID)
        self.assertEqual(campaign.status, CampaignStatus.DRAFT)
        self.assertEqual(campaign.campaign_type, CampaignType.TASK)
        self.assertEqual(campaign.budget, Decimal("500.00"))
        self.assertEqual(campaign.owner, self.user)
        self.assertTrue(str(campaign).startswith("Summer Video Campaign"))

    def test_campaign_types_and_statuses(self):
        for ctype in CampaignType.values:
            c = Campaign.objects.create(
                owner=self.user,
                title=f"Test {ctype}",
                campaign_type=ctype,
            )
            self.assertEqual(c.campaign_type, ctype)

        for status_val in CampaignStatus.values:
            c = Campaign.objects.create(
                owner=self.user,
                title=f"Status {status_val}",
                status=status_val,
            )
            self.assertEqual(c.status, status_val)

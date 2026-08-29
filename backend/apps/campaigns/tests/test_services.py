from decimal import Decimal
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError, PermissionDenied
from apps.campaigns.models import Campaign, CampaignType, CampaignStatus
from apps.campaigns.services import CampaignService

User = get_user_model()


class CampaignServiceTest(TestCase):
    def setUp(self):
        # Advertiser-capable user (not admin/staff)
        self.owner = User.objects.create_user(
            email="owner@example.com",
            username="owner1",
            password="Password123!",
        )
        self.owner.role = "advertiser"
        self.owner.save()
        # Ordinary user without advertiser capabilities
        self.ordinary_user = User.objects.create_user(
            email="ordinary@example.com",
            username="ordinary1",
            password="Password123!",
        )
        # Superuser / Admin
        self.admin = User.objects.create_superuser(
            email="admin@example.com",
            username="admin1",
            password="Password123!",
        )

    def test_ordinary_user_cannot_create_campaign(self):
        with self.assertRaises(PermissionDenied):
            CampaignService.create_campaign(
                owner=self.ordinary_user,
                campaign_type=CampaignType.ADVERTISEMENT,
                title="Unauthorized Campaign",
            )

    def test_create_campaign_service(self):
        campaign = CampaignService.create_campaign(
            owner=self.owner,
            campaign_type=CampaignType.ADVERTISEMENT,
            title="Ad Campaign 1",
            description="Promo ad",
            budget=Decimal("150.00"),
        )
        self.assertEqual(campaign.status, CampaignStatus.DRAFT)
        self.assertEqual(campaign.title, "Ad Campaign 1")
        self.assertEqual(campaign.budget, Decimal("150.00"))

    def test_submit_for_review(self):
        campaign = CampaignService.create_campaign(
            owner=self.owner,
            campaign_type=CampaignType.TASK,
            title="Task Review Test",
        )
        # Non-owner fails
        with self.assertRaises(PermissionDenied):
            CampaignService.submit_for_review(campaign, self.ordinary_user)

        # Owner succeeds
        updated = CampaignService.submit_for_review(campaign, self.owner)
        self.assertEqual(updated.status, CampaignStatus.PENDING_REVIEW)

    def test_approve_campaign(self):
        campaign = CampaignService.create_campaign(
            owner=self.owner,
            campaign_type=CampaignType.TASK,
            title="Approval Test",
        )
        CampaignService.submit_for_review(campaign, self.owner)

        # Non-admin fails
        with self.assertRaises(PermissionDenied):
            CampaignService.approve_campaign(campaign, self.owner)

        # Admin succeeds
        approved = CampaignService.approve_campaign(campaign, self.admin)
        self.assertEqual(approved.status, CampaignStatus.ACTIVE)
        self.assertIsNotNone(approved.start_date)

    def test_reject_campaign(self):
        campaign = CampaignService.create_campaign(
            owner=self.owner,
            campaign_type=CampaignType.SPONSORED_CONTENT,
            title="Reject Test",
        )
        CampaignService.submit_for_review(campaign, self.owner)

        rejected = CampaignService.reject_campaign(campaign, self.admin, reason="Quality guidelines not met")
        self.assertEqual(rejected.status, CampaignStatus.REJECTED)

    def test_pause_campaign(self):
        campaign = CampaignService.create_campaign(
            owner=self.owner,
            campaign_type=CampaignType.TASK,
            title="Pause Test",
        )
        CampaignService.submit_for_review(campaign, self.owner)
        CampaignService.approve_campaign(campaign, self.admin)

        # Pause as owner
        paused = CampaignService.pause_campaign(campaign, self.owner)
        self.assertEqual(paused.status, CampaignStatus.PAUSED)

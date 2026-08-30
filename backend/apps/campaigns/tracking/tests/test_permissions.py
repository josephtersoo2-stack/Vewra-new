from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.exceptions import PermissionDenied

from apps.campaigns.models import (
    Campaign,
    CampaignType,
    CampaignStatus,
)
from apps.campaigns.tracking.services import AdvertisementTrackingService

User = get_user_model()


class TrackingPermissionsTests(TestCase):
    def setUp(self):
        self.advertiser_a = User.objects.create_user(
            username="advertiser_alpha",
            email="alpha@example.com",
            password="StrongPassword123!",
        )
        self.advertiser_a.role = "advertiser"
        self.advertiser_a.is_advertiser = True

        self.advertiser_b = User.objects.create_user(
            username="advertiser_beta",
            email="beta@example.com",
            password="StrongPassword123!",
        )
        self.advertiser_b.role = "advertiser"
        self.advertiser_b.is_advertiser = True

        self.earner_user = User.objects.create_user(
            username="earner_bob",
            email="earner@example.com",
            password="StrongPassword123!",
        )
        self.earner_user.role = "earner"
        self.earner_user.is_advertiser = False

        self.admin_user = User.objects.create_superuser(
            username="admin_super",
            email="admin@example.com",
            password="StrongPassword123!",
        )

        self.campaign_a = Campaign.objects.create(
            owner=self.advertiser_a,
            title="Alpha Exclusive Campaign",
            campaign_type=CampaignType.ADVERTISEMENT,
            status=CampaignStatus.ACTIVE,
        )

    def test_owner_can_view_campaign_analytics(self):
        stats = AdvertisementTrackingService.generate_campaign_statistics(
            campaign_id=self.campaign_a.id,
            user=self.advertiser_a,
        )
        self.assertEqual(stats["campaign_id"], str(self.campaign_a.id))

    def test_other_advertiser_cannot_view_campaign_analytics(self):
        with self.assertRaises(PermissionDenied):
            AdvertisementTrackingService.generate_campaign_statistics(
                campaign_id=self.campaign_a.id,
                user=self.advertiser_b,
            )

    def test_earner_user_cannot_view_campaign_analytics(self):
        with self.assertRaises(PermissionDenied):
            AdvertisementTrackingService.generate_campaign_statistics(
                campaign_id=self.campaign_a.id,
                user=self.earner_user,
            )

    def test_admin_can_view_any_campaign_analytics(self):
        stats = AdvertisementTrackingService.generate_campaign_statistics(
            campaign_id=self.campaign_a.id,
            user=self.admin_user,
        )
        self.assertEqual(stats["campaign_id"], str(self.campaign_a.id))

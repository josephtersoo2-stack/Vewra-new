from decimal import Decimal
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.core.exceptions import PermissionDenied
from apps.campaigns.models import (
    Campaign,
    CampaignType,
    CampaignStatus,
    CampaignMedia,
    MediaType,
    MediaStatus,
    CampaignAdPlacement,
    PlacementType,
    PlacementStatus,
)
from apps.campaigns.services import CampaignAdDeliveryService

User = get_user_model()


class PlacementPermissionTests(TestCase):
    def setUp(self):
        self.advertiser_a = User.objects.create_user(
            username="perm_ad_a",
            email="ad_a@vewra.io",
            password="Password123!",
        )
        self.advertiser_a.role = "advertiser"
        self.advertiser_a.save()

        self.advertiser_b = User.objects.create_user(
            username="perm_ad_b",
            email="ad_b@vewra.io",
            password="Password123!",
        )
        self.advertiser_b.role = "advertiser"
        self.advertiser_b.save()

        self.admin_user = User.objects.create_superuser(
            username="perm_admin",
            email="admin_perm@vewra.io",
            password="Password123!",
        )
        self.campaign_a = Campaign.objects.create(
            owner=self.advertiser_a,
            campaign_type=CampaignType.ADVERTISEMENT,
            title="Advertiser A Campaign",
            status=CampaignStatus.ACTIVE,
        )
        self.dummy_image = SimpleUploadedFile(
            name="banner.jpg",
            content=b"\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x01\x00`\x00`\x00\x00\xff\xdb\x00C\x00\x08\x06\x06\x07\x06\x05\x08\x07\x07\x07\t\t\x08\n\x0c\x14\r\x0c\x0b\x0b\x0c\x19\x12\x13\x0f\x14\x1d\x1a\x1f\x1e\x1d\x1a\x1c\x1c $.' \",#\x1c\x1c(7),01444\x1f'9=82<.342\xff\xc0\x00\x11\x08\x00\x01\x00\x01\x01\x01\x11\x00\xff\xc4\x00\x1f\x00\x00\x01\x05\x01\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x04\x05\x06\x07\x08\t\n\x0b\xff\xda\x00\x08\x01\x01\x00\x00?\x00\xbf\x00\xff\xd9",
            content_type="image/jpeg",
        )
        self.media_a = CampaignMedia.objects.create(
            campaign=self.campaign_a,
            uploaded_by=self.advertiser_a,
            media_type=MediaType.IMAGE,
            file=self.dummy_image,
            title="Image A",
            status=MediaStatus.READY,
        )
        self.placement_a = CampaignAdPlacement.objects.create(
            campaign=self.campaign_a,
            media=self.media_a,
            placement_type=PlacementType.HOME_FEED,
            status=PlacementStatus.DRAFT,
            created_by=self.advertiser_a,
        )

    def test_advertiser_b_cannot_create_placement_on_campaign_a(self):
        with self.assertRaises(PermissionDenied):
            CampaignAdDeliveryService.create_placement(
                user=self.advertiser_b,
                campaign_id=str(self.campaign_a.id),
                media_id=str(self.media_a.id),
                placement_type=PlacementType.HEADER,
            )

    def test_advertiser_b_cannot_disable_placement_a(self):
        with self.assertRaises(PermissionDenied):
            CampaignAdDeliveryService.disable_placement(
                user=self.advertiser_b,
                placement=self.placement_a,
            )

    def test_admin_can_manage_placement_a(self):
        disabled = CampaignAdDeliveryService.disable_placement(
            user=self.admin_user,
            placement=self.placement_a,
        )
        self.assertEqual(disabled.status, PlacementStatus.DISABLED)

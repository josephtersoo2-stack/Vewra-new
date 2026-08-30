import uuid
from decimal import Decimal
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.utils import timezone
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

User = get_user_model()


class CampaignAdPlacementModelTests(TestCase):
    def setUp(self):
        self.advertiser = User.objects.create_user(
            username="ad_model_user",
            email="ad_model@vewra.io",
            password="Password123!",
        )
        self.advertiser.role = "advertiser"
        self.advertiser.save()
        self.campaign = Campaign.objects.create(
            owner=self.advertiser,
            campaign_type=CampaignType.ADVERTISEMENT,
            title="Model Test Campaign",
            budget=Decimal("500.00"),
            status=CampaignStatus.ACTIVE,
        )
        self.dummy_image = SimpleUploadedFile(
            name="banner.jpg",
            content=b"\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x01\x00`\x00`\x00\x00\xff\xdb\x00C\x00\x08\x06\x06\x07\x06\x05\x08\x07\x07\x07\t\t\x08\n\x0c\x14\r\x0c\x0b\x0b\x0c\x19\x12\x13\x0f\x14\x1d\x1a\x1f\x1e\x1d\x1a\x1c\x1c $.' \",#\x1c\x1c(7),01444\x1f'9=82<.342\xff\xc0\x00\x11\x08\x00\x01\x00\x01\x01\x01\x11\x00\xff\xc4\x00\x1f\x00\x00\x01\x05\x01\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x04\x05\x06\x07\x08\t\n\x0b\xff\xda\x00\x08\x01\x01\x00\x00?\x00\xbf\x00\xff\xd9",
            content_type="image/jpeg",
        )
        self.media = CampaignMedia.objects.create(
            campaign=self.campaign,
            uploaded_by=self.advertiser,
            media_type=MediaType.BANNER,
            file=self.dummy_image,
            title="Banner Asset",
            file_size=1024,
            mime_type="image/jpeg",
            width=728,
            height=90,
            status=MediaStatus.READY,
        )

    def test_placement_creation_defaults(self):
        placement = CampaignAdPlacement.objects.create(
            campaign=self.campaign,
            media=self.media,
            placement_type=PlacementType.HOME_FEED,
            created_by=self.advertiser,
        )
        self.assertIsInstance(placement.id, uuid.UUID)
        self.assertEqual(placement.status, PlacementStatus.DRAFT)
        self.assertEqual(placement.priority, 10)
        self.assertEqual(placement.placement_type, PlacementType.HOME_FEED)
        self.assertEqual(placement.campaign, self.campaign)
        self.assertEqual(placement.media, self.media)
        self.assertEqual(placement.created_by, self.advertiser)
        self.assertIn("Home Feed", str(placement))

    def test_placement_cascade_deletion(self):
        placement = CampaignAdPlacement.objects.create(
            campaign=self.campaign,
            media=self.media,
            placement_type=PlacementType.HEADER,
        )
        placement_id = placement.id
        self.campaign.delete()
        self.assertFalse(CampaignAdPlacement.objects.filter(id=placement_id).exists())

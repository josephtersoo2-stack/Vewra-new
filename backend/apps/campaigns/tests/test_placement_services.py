import datetime
from decimal import Decimal
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.core.exceptions import ValidationError, PermissionDenied
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
from apps.campaigns.services import CampaignAdDeliveryService

User = get_user_model()


class CampaignAdDeliveryServiceTests(TestCase):
    def setUp(self):
        self.advertiser = User.objects.create_user(
            username="service_advertiser",
            email="serv_ad@vewra.io",
            password="Password123!",
        )
        self.advertiser.role = "advertiser"
        self.advertiser.save()
        self.other_user = User.objects.create_user(
            username="other_earner",
            email="other_earner@vewra.io",
            password="Password123!",
        )
        self.campaign = Campaign.objects.create(
            owner=self.advertiser,
            campaign_type=CampaignType.ADVERTISEMENT,
            title="Service Active Campaign",
            budget=Decimal("1000.00"),
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
            title="Service Banner",
            file_size=1024,
            mime_type="image/jpeg",
            status=MediaStatus.READY,
        )

    def test_create_placement_success(self):
        placement = CampaignAdDeliveryService.create_placement(
            user=self.advertiser,
            campaign_id=str(self.campaign.id),
            media_id=str(self.media.id),
            placement_type=PlacementType.HOME_FEED,
            priority=25,
            status=PlacementStatus.DRAFT,
        )
        self.assertEqual(placement.campaign, self.campaign)
        self.assertEqual(placement.media, self.media)
        self.assertEqual(placement.priority, 25)
        self.assertEqual(placement.status, PlacementStatus.DRAFT)

    def test_create_placement_rejects_non_advertiser(self):
        with self.assertRaises(PermissionDenied):
            CampaignAdDeliveryService.create_placement(
                user=self.other_user,
                campaign_id=str(self.campaign.id),
                media_id=str(self.media.id),
                placement_type=PlacementType.HEADER,
            )

    def test_create_placement_rejects_cross_campaign_media(self):
        other_campaign = Campaign.objects.create(
            owner=self.advertiser,
            campaign_type=CampaignType.TASK,
            title="Other Campaign",
            status=CampaignStatus.ACTIVE,
        )
        with self.assertRaises(ValidationError):
            CampaignAdDeliveryService.create_placement(
                user=self.advertiser,
                campaign_id=str(other_campaign.id),
                media_id=str(self.media.id),  # media belongs to self.campaign
                placement_type=PlacementType.HEADER,
            )

    def test_create_placement_rejects_disabled_media(self):
        self.media.status = MediaStatus.DISABLED
        self.media.save()
        with self.assertRaises(ValidationError):
            CampaignAdDeliveryService.create_placement(
                user=self.advertiser,
                campaign_id=str(self.campaign.id),
                media_id=str(self.media.id),
                placement_type=PlacementType.HEADER,
            )

    def test_activate_pause_disable_lifecycle(self):
        placement = CampaignAdDeliveryService.create_placement(
            user=self.advertiser,
            campaign_id=str(self.campaign.id),
            media_id=str(self.media.id),
            placement_type=PlacementType.POPUP,
            status=PlacementStatus.DRAFT,
        )
        self.assertEqual(placement.status, PlacementStatus.DRAFT)

        # Activate
        activated = CampaignAdDeliveryService.activate_placement(self.advertiser, placement)
        self.assertEqual(activated.status, PlacementStatus.ACTIVE)

        # Pause
        paused = CampaignAdDeliveryService.pause_placement(self.advertiser, activated)
        self.assertEqual(paused.status, PlacementStatus.PAUSED)

        # Disable
        disabled = CampaignAdDeliveryService.disable_placement(self.advertiser, paused)
        self.assertEqual(disabled.status, PlacementStatus.DISABLED)

        # Restore
        restored = CampaignAdDeliveryService.restore_placement(self.advertiser, disabled)
        self.assertEqual(restored.status, PlacementStatus.ACTIVE)

    def test_activate_rejects_expired_placement(self):
        past_date = timezone.now() - datetime.timedelta(days=2)
        placement = CampaignAdPlacement.objects.create(
            campaign=self.campaign,
            media=self.media,
            placement_type=PlacementType.HEADER,
            status=PlacementStatus.DRAFT,
            end_date=past_date,
        )
        with self.assertRaises(ValidationError):
            CampaignAdDeliveryService.activate_placement(self.advertiser, placement)

    def test_get_active_ads_by_location_filtering_and_priority(self):
        # Create 2 active placements with different priorities
        p1 = CampaignAdPlacement.objects.create(
            campaign=self.campaign,
            media=self.media,
            placement_type=PlacementType.HOME_FEED,
            status=PlacementStatus.ACTIVE,
            priority=10,
        )
        p2 = CampaignAdPlacement.objects.create(
            campaign=self.campaign,
            media=self.media,
            placement_type=PlacementType.HOME_FEED,
            status=PlacementStatus.ACTIVE,
            priority=50,  # Higher priority
        )
        # Create a paused placement (should not be delivered)
        CampaignAdPlacement.objects.create(
            campaign=self.campaign,
            media=self.media,
            placement_type=PlacementType.HOME_FEED,
            status=PlacementStatus.PAUSED,
            priority=100,
        )

        active_ads = list(CampaignAdDeliveryService.get_active_ads_by_location(PlacementType.HOME_FEED))
        self.assertEqual(len(active_ads), 2)
        self.assertEqual(active_ads[0].id, p2.id)  # p2 priority 50 first
        self.assertEqual(active_ads[1].id, p1.id)  # p1 priority 10 second

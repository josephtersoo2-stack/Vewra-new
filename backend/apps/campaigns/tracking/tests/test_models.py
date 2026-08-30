import uuid
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile

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
from apps.campaigns.tracking.models import (
    ClickType,
    AdvertisementImpression,
    AdvertisementClick,
    AdvertisementVideoEngagement,
)

User = get_user_model()


class TrackingModelTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="advertiser_tracking_user",
            email="advertiser_track@example.com",
            password="StrongPassword123!",
        )
        self.campaign = Campaign.objects.create(
            owner=self.user,
            title="Test Analytics Campaign",
            campaign_type=CampaignType.ADVERTISEMENT,
            status=CampaignStatus.ACTIVE,
        )
        dummy_file = SimpleUploadedFile("banner.png", b"test content", content_type="image/png")
        self.media = CampaignMedia.objects.create(
            campaign=self.campaign,
            uploaded_by=self.user,
            media_type=MediaType.IMAGE,
            file=dummy_file,
            title="Promo Banner Creative",
            status=MediaStatus.READY,
        )
        self.placement = CampaignAdPlacement.objects.create(
            campaign=self.campaign,
            media=self.media,
            placement_type=PlacementType.HOME_FEED,
            status=PlacementStatus.ACTIVE,
            priority=20,
            created_by=self.user,
        )

    def test_impression_creation_and_defaults(self):
        impression = AdvertisementImpression.objects.create(
            campaign=self.campaign,
            placement=self.placement,
            media=self.media,
            user=self.user,
            session_id="session-xyz-123",
            device_id="device-abc-456",
            ip_hash="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            user_agent="Mozilla/5.0 Mobile",
        )

        self.assertIsInstance(impression.id, uuid.UUID)
        self.assertEqual(impression.campaign, self.campaign)
        self.assertEqual(impression.placement, self.placement)
        self.assertEqual(impression.media, self.media)
        self.assertEqual(impression.user, self.user)
        self.assertIn(self.campaign.title, str(impression))

    def test_click_creation_and_relationships(self):
        impression = AdvertisementImpression.objects.create(
            campaign=self.campaign,
            placement=self.placement,
            media=self.media,
            user=self.user,
            session_id="session-xyz-123",
        )
        click = AdvertisementClick.objects.create(
            impression=impression,
            campaign=self.campaign,
            media=self.media,
            user=self.user,
            click_type=ClickType.BANNER_CLICK,
            session_id="session-xyz-123",
        )

        self.assertIsInstance(click.id, uuid.UUID)
        self.assertEqual(click.impression, impression)
        self.assertEqual(click.click_type, ClickType.BANNER_CLICK)
        self.assertIn("Banner Click", str(click))

    def test_video_engagement_creation(self):
        video_file = SimpleUploadedFile("ad.mp4", b"video content", content_type="video/mp4")
        video_media = CampaignMedia.objects.create(
            campaign=self.campaign,
            uploaded_by=self.user,
            media_type=MediaType.VIDEO,
            file=video_file,
            title="Video Spot",
            duration_seconds=30,
            status=MediaStatus.READY,
        )
        engagement = AdvertisementVideoEngagement.objects.create(
            campaign=self.campaign,
            media=video_media,
            user=self.user,
            session_id="session-vid-999",
            watched_seconds=28.5,
            completion_percentage=95.0,
            completed=True,
        )

        self.assertIsInstance(engagement.id, uuid.UUID)
        self.assertTrue(engagement.completed)
        self.assertEqual(engagement.completion_percentage, 95.0)
        self.assertIn("Completed", str(engagement))

    def test_cascade_deletion(self):
        impression = AdvertisementImpression.objects.create(
            campaign=self.campaign,
            placement=self.placement,
            media=self.media,
            session_id="session-cascade",
        )
        AdvertisementClick.objects.create(
            impression=impression,
            campaign=self.campaign,
            media=self.media,
            session_id="session-cascade",
        )
        AdvertisementVideoEngagement.objects.create(
            campaign=self.campaign,
            media=self.media,
            session_id="session-cascade",
        )

        self.campaign.delete()
        self.assertEqual(AdvertisementImpression.objects.count(), 0)
        self.assertEqual(AdvertisementClick.objects.count(), 0)
        self.assertEqual(AdvertisementVideoEngagement.objects.count(), 0)

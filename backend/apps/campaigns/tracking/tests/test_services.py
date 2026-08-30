from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError, PermissionDenied
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
from apps.campaigns.tracking.services import AdvertisementTrackingService

User = get_user_model()


class TrackingServiceTests(TestCase):
    def setUp(self):
        self.advertiser = User.objects.create_user(
            username="advertiser_one",
            email="adv1@example.com",
            password="StrongPassword123!",
        )
        self.advertiser.role = "advertiser"
        self.advertiser.is_advertiser = True

        self.campaign = Campaign.objects.create(
            owner=self.advertiser,
            title="Active Brand Campaign",
            campaign_type=CampaignType.ADVERTISEMENT,
            status=CampaignStatus.ACTIVE,
        )
        dummy_file = SimpleUploadedFile("banner.png", b"image bytes", content_type="image/png")
        self.media = CampaignMedia.objects.create(
            campaign=self.campaign,
            uploaded_by=self.advertiser,
            media_type=MediaType.IMAGE,
            file=dummy_file,
            title="Display Banner",
            status=MediaStatus.READY,
        )
        self.placement = CampaignAdPlacement.objects.create(
            campaign=self.campaign,
            media=self.media,
            placement_type=PlacementType.HOME_FEED,
            status=PlacementStatus.ACTIVE,
            priority=15,
            created_by=self.advertiser,
        )

        # Video media for engagement tests
        video_file = SimpleUploadedFile("video.mp4", b"video bytes", content_type="video/mp4")
        self.video_media = CampaignMedia.objects.create(
            campaign=self.campaign,
            uploaded_by=self.advertiser,
            media_type=MediaType.VIDEO,
            file=video_file,
            title="Video Spot Creative",
            duration_seconds=20,
            status=MediaStatus.READY,
        )

    def test_record_impression_success(self):
        impression = AdvertisementTrackingService.record_impression(
            campaign_id=self.campaign.id,
            placement_id=self.placement.id,
            media_id=self.media.id,
            user=self.advertiser,
            session_id="session-user-1",
            ip_address="192.168.1.100",
            user_agent="VewraApp/1.0",
        )

        self.assertIsNotNone(impression.id)
        self.assertEqual(impression.campaign, self.campaign)
        self.assertEqual(impression.placement, self.placement)
        self.assertEqual(impression.media, self.media)
        self.assertTrue(len(impression.ip_hash) > 0)

    def test_record_impression_inactive_campaign_rejected(self):
        self.campaign.status = CampaignStatus.PAUSED
        self.campaign.save()

        with self.assertRaises(ValidationError) as ctx:
            AdvertisementTrackingService.record_impression(
                campaign_id=self.campaign.id,
                placement_id=self.placement.id,
                media_id=self.media.id,
            )
        self.assertIn("active campaigns", str(ctx.exception))

    def test_record_impression_inactive_placement_rejected(self):
        self.placement.status = PlacementStatus.PAUSED
        self.placement.save()

        with self.assertRaises(ValidationError) as ctx:
            AdvertisementTrackingService.record_impression(
                campaign_id=self.campaign.id,
                placement_id=self.placement.id,
                media_id=self.media.id,
            )
        self.assertIn("active placements", str(ctx.exception))

    def test_record_impression_duplicate_throttling(self):
        imp1 = AdvertisementTrackingService.record_impression(
            campaign_id=self.campaign.id,
            placement_id=self.placement.id,
            media_id=self.media.id,
            session_id="same-session-id",
        )
        imp2 = AdvertisementTrackingService.record_impression(
            campaign_id=self.campaign.id,
            placement_id=self.placement.id,
            media_id=self.media.id,
            session_id="same-session-id",
        )

        self.assertEqual(imp1.id, imp2.id)
        self.assertEqual(AdvertisementImpression.objects.count(), 1)

    def test_record_click_success(self):
        impression = AdvertisementTrackingService.record_impression(
            campaign_id=self.campaign.id,
            placement_id=self.placement.id,
            media_id=self.media.id,
            session_id="sess-click-test",
        )
        click = AdvertisementTrackingService.record_click(
            campaign_id=self.campaign.id,
            media_id=self.media.id,
            impression_id=impression.id,
            click_type=ClickType.BANNER_CLICK,
            session_id="sess-click-test",
        )

        self.assertIsNotNone(click.id)
        self.assertEqual(click.impression, impression)
        self.assertEqual(click.click_type, ClickType.BANNER_CLICK)

    def test_record_video_progress_and_completion_calculation(self):
        # Progress 1: 10 seconds / 20 seconds duration -> 50% completion
        eng1 = AdvertisementTrackingService.record_video_progress(
            campaign_id=self.campaign.id,
            media_id=self.video_media.id,
            session_id="video-sess-001",
            watched_seconds=10.0,
        )
        self.assertEqual(eng1.watched_seconds, 10.0)
        self.assertEqual(eng1.completion_percentage, 50.0)
        self.assertFalse(eng1.completed)

        # Progress 2: 19.5 seconds -> 97.5% completion -> completed=True
        eng2 = AdvertisementTrackingService.record_video_progress(
            campaign_id=self.campaign.id,
            media_id=self.video_media.id,
            session_id="video-sess-001",
            watched_seconds=19.5,
        )
        self.assertEqual(eng2.watched_seconds, 19.5)
        self.assertEqual(eng2.completion_percentage, 97.5)
        self.assertTrue(eng2.completed)

    def test_generate_campaign_statistics(self):
        # Create 2 impressions
        imp1 = AdvertisementTrackingService.record_impression(
            campaign_id=self.campaign.id,
            placement_id=self.placement.id,
            media_id=self.media.id,
            session_id="session-user-a",
        )
        imp2 = AdvertisementTrackingService.record_impression(
            campaign_id=self.campaign.id,
            placement_id=self.placement.id,
            media_id=self.media.id,
            session_id="session-user-b",
        )
        # Create 1 click
        AdvertisementTrackingService.record_click(
            campaign_id=self.campaign.id,
            media_id=self.media.id,
            impression_id=imp1.id,
            click_type=ClickType.BANNER_CLICK,
            session_id="session-user-a",
        )
        # Create 1 video completion
        AdvertisementTrackingService.record_video_progress(
            campaign_id=self.campaign.id,
            media_id=self.video_media.id,
            session_id="session-user-a",
            watched_seconds=20.0,
        )

        stats = AdvertisementTrackingService.generate_campaign_statistics(
            campaign_id=self.campaign.id,
            user=self.advertiser,
        )

        self.assertEqual(stats["total_impressions"], 2)
        self.assertEqual(stats["unique_viewers"], 2)
        self.assertEqual(stats["total_clicks"], 1)
        self.assertEqual(stats["click_through_rate"], 50.0)
        self.assertEqual(stats["video_metrics"]["total_plays"], 1)
        self.assertEqual(stats["video_metrics"]["completions"], 1)
        self.assertEqual(stats["video_metrics"]["completion_rate"], 100.0)
        self.assertTrue(len(stats["creatives_performance"]) > 0)

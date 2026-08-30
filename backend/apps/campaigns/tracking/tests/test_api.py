from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse

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
)

User = get_user_model()


class TrackingAPITests(APITestCase):
    def setUp(self):
        self.advertiser = User.objects.create_user(
            username="advertiser_api",
            email="adv_api@example.com",
            password="StrongPassword123!",
        )
        self.advertiser.role = "advertiser"
        self.advertiser.is_advertiser = True

        self.campaign = Campaign.objects.create(
            owner=self.advertiser,
            title="API Tracking Campaign",
            campaign_type=CampaignType.ADVERTISEMENT,
            status=CampaignStatus.ACTIVE,
        )
        dummy_file = SimpleUploadedFile("banner.jpg", b"image bytes", content_type="image/jpeg")
        self.media = CampaignMedia.objects.create(
            campaign=self.campaign,
            uploaded_by=self.advertiser,
            media_type=MediaType.IMAGE,
            file=dummy_file,
            title="Promo Banner",
            status=MediaStatus.READY,
        )
        self.placement = CampaignAdPlacement.objects.create(
            campaign=self.campaign,
            media=self.media,
            placement_type=PlacementType.HOME_FEED,
            status=PlacementStatus.ACTIVE,
            priority=10,
            created_by=self.advertiser,
        )
        # Video media
        video_file = SimpleUploadedFile("video.mp4", b"video bytes", content_type="video/mp4")
        self.video_media = CampaignMedia.objects.create(
            campaign=self.campaign,
            uploaded_by=self.advertiser,
            media_type=MediaType.VIDEO,
            file=video_file,
            title="Video Creative",
            duration_seconds=30,
            status=MediaStatus.READY,
        )

    def test_record_impression_api(self):
        url = reverse("ad-record-impression")
        payload = {
            "campaign_id": str(self.campaign.id),
            "placement_id": str(self.placement.id),
            "media_id": str(self.media.id),
            "session_id": "client-sess-100",
            "device_id": "device-pixel-8",
        }
        response = self.client.post(url, payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertIn("impression_id", response.data)

    def test_record_click_api(self):
        url = reverse("ad-record-click")
        payload = {
            "campaign_id": str(self.campaign.id),
            "media_id": str(self.media.id),
            "click_type": ClickType.BANNER_CLICK,
            "session_id": "client-sess-100",
        }
        response = self.client.post(url, payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertIn("click_id", response.data)

    def test_record_video_progress_api(self):
        url = reverse("ad-record-video-progress")
        payload = {
            "campaign_id": str(self.campaign.id),
            "media_id": str(self.video_media.id),
            "session_id": "video-sess-200",
            "watched_seconds": 15.0,
        }
        response = self.client.post(url, payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["watched_seconds"], 15.0)
        self.assertEqual(response.data["completion_percentage"], 50.0)
        self.assertFalse(response.data["completed"])

    def test_get_campaign_analytics_api(self):
        self.client.force_authenticate(user=self.advertiser)
        url = reverse("campaigns:campaign-analytics", kwargs={"campaign_id": str(self.campaign.id)})
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["campaign_id"], str(self.campaign.id))
        self.assertIn("total_impressions", response.data)
        self.assertIn("click_through_rate", response.data)
        self.assertIn("creatives_performance", response.data)

    def test_get_advertiser_overview_analytics_api(self):
        self.client.force_authenticate(user=self.advertiser)
        url = reverse("advertiser-analytics")
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("total_campaigns", response.data)
        self.assertIn("overall_ctr", response.data)

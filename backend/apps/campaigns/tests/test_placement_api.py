from decimal import Decimal
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from apps.authentication.services import AuthService
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


class CampaignAdPlacementApiTests(APITestCase):
    def setUp(self):
        self.advertiser = User.objects.create_user(
            username="api_advertiser",
            email="api_ad@vewra.io",
            password="Password123!",
        )
        self.advertiser.role = "advertiser"
        self.advertiser.save()

        self.normal_user = User.objects.create_user(
            username="api_normal",
            email="api_norm@vewra.io",
            password="Password123!",
        )
        self.admin_user = User.objects.create_superuser(
            username="api_admin",
            email="admin_api@vewra.io",
            password="Password123!",
        )

        self.ad_tokens = AuthService.get_tokens_for_user(self.advertiser)
        self.normal_tokens = AuthService.get_tokens_for_user(self.normal_user)
        self.admin_tokens = AuthService.get_tokens_for_user(self.admin_user)

        self.campaign = Campaign.objects.create(
            owner=self.advertiser,
            campaign_type=CampaignType.ADVERTISEMENT,
            title="API Active Campaign",
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
            title="Ad Banner",
            file_size=1024,
            mime_type="image/jpeg",
            width=728,
            height=90,
            status=MediaStatus.READY,
        )
        self.placement = CampaignAdPlacement.objects.create(
            campaign=self.campaign,
            media=self.media,
            placement_type=PlacementType.HOME_FEED,
            status=PlacementStatus.ACTIVE,
            priority=20,
            created_by=self.advertiser,
        )

    def test_public_ad_delivery_endpoint(self):
        url = f"/api/v1/ads/{PlacementType.HOME_FEED}/"
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["placement_type"], PlacementType.HOME_FEED)
        self.assertEqual(response.data["count"], 1)
        self.assertEqual(response.data["ads"][0]["id"], str(self.placement.id))
        self.assertEqual(response.data["ads"][0]["campaign_title"], "API Active Campaign")

    def test_create_placement_api_advertiser(self):
        self.client.force_authenticate(user=self.advertiser)
        url = f"/api/v1/campaigns/{self.campaign.id}/placements/"
        payload = {
            "media_id": str(self.media.id),
            "placement_type": PlacementType.HEADER,
            "status": PlacementStatus.ACTIVE,
            "priority": 15,
        }
        response = self.client.post(url, payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["placement"]["placement_type"], PlacementType.HEADER)
        self.assertEqual(response.data["placement"]["status"], PlacementStatus.ACTIVE)

    def test_create_placement_api_blocked_for_normal_user(self):
        self.client.force_authenticate(user=self.normal_user)
        url = f"/api/v1/campaigns/{self.campaign.id}/placements/"
        payload = {
            "media_id": str(self.media.id),
            "placement_type": PlacementType.HEADER,
        }
        response = self.client.post(url, payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_update_and_disable_placement_api(self):
        self.client.force_authenticate(user=self.advertiser)
        url = f"/api/v1/ad-placement/{self.placement.id}/"
        
        # Patch priority
        patch_res = self.client.patch(url, {"priority": 99}, format="json")
        self.assertEqual(patch_res.status_code, status.HTTP_200_OK)
        self.assertEqual(patch_res.data["placement"]["priority"], 99)

        # Delete (soft disable)
        del_res = self.client.delete(url)
        self.assertEqual(del_res.status_code, status.HTTP_200_OK)
        self.assertEqual(del_res.data["placement"]["status"], PlacementStatus.DISABLED)

        # Restore
        restore_url = f"/api/v1/ad-placement/{self.placement.id}/restore/"
        rest_res = self.client.post(restore_url)
        self.assertEqual(rest_res.status_code, status.HTTP_200_OK)
        self.assertEqual(rest_res.data["placement"]["status"], PlacementStatus.ACTIVE)

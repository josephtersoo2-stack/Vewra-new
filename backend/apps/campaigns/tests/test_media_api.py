import io
from decimal import Decimal
from PIL import Image
from django.urls import reverse
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework.test import APITestCase
from rest_framework import status

from apps.campaigns.models import Campaign, CampaignType, CampaignStatus, CampaignMedia, MediaType, MediaStatus

User = get_user_model()


class CampaignMediaAPITest(APITestCase):
    def setUp(self):
        # Advertiser
        self.owner = User.objects.create_user(
            email="adv_api_owner@test.com",
            username="adv_api_owner",
            password="Password123!",
        )
        self.owner.role = "advertiser"
        self.owner.save()

        # Other Advertiser
        self.other_owner = User.objects.create_user(
            email="other_adv_api@test.com",
            username="other_adv_api",
            password="Password123!",
        )
        self.other_owner.role = "advertiser"
        self.other_owner.save()

        # Normal User
        self.normal_user = User.objects.create_user(
            email="normal_api_user@test.com",
            username="normal_api_user",
            password="Password123!",
        )

        # Platform Admin
        self.admin = User.objects.create_superuser(
            email="admin_media_api@test.com",
            username="admin_media_api",
            password="Password123!",
        )

        # Campaign
        self.campaign = Campaign.objects.create(
            owner=self.owner,
            campaign_type=CampaignType.ADVERTISEMENT,
            title="Interactive App Promo",
            budget=Decimal("1500.00"),
            status=CampaignStatus.ACTIVE,
        )

        self.media_list_url = reverse("campaigns:campaign-media-list", kwargs={"campaign_id": self.campaign.id})
        self.media_upload_url = reverse("campaigns:campaign-media-upload", kwargs={"campaign_id": self.campaign.id})

    def _create_test_image(self, filename="banner.png", width=300, height=250):
        img = Image.new("RGB", (width, height), color=(50, 150, 250))
        byte_arr = io.BytesIO()
        img.save(byte_arr, format="PNG")
        byte_arr.seek(0)
        return SimpleUploadedFile(filename, byte_arr.read(), content_type="image/png")

    def test_upload_media_api_as_advertiser(self):
        self.client.force_authenticate(user=self.owner)
        file = self._create_test_image("hero_banner.png", 728, 90)

        data = {
            "file": file,
            "media_type": MediaType.BANNER,
            "title": "728x90 Header Ad",
            "description": "Premium top placement creative",
        }
        response = self.client.post(self.media_upload_url, data, format="multipart")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["media"]["title"], "728x90 Header Ad")
        self.assertEqual(response.data["media"]["width"], 728)
        self.assertEqual(response.data["media"]["height"], 90)
        self.assertEqual(response.data["media"]["status"], MediaStatus.READY)

    def test_upload_media_api_blocked_for_normal_user(self):
        self.client.force_authenticate(user=self.normal_user)
        file = self._create_test_image("test.png")

        data = {
            "file": file,
            "media_type": MediaType.IMAGE,
            "title": "Unauthorized Upload",
        }
        response = self.client.post(self.media_upload_url, data, format="multipart")
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_upload_media_api_rejects_invalid_file(self):
        self.client.force_authenticate(user=self.owner)
        exe_file = SimpleUploadedFile("payload.exe", b"MZ\x90\x00executable", content_type="application/x-msdownload")

        data = {
            "file": exe_file,
            "media_type": MediaType.IMAGE,
            "title": "Dangerous File",
        }
        response = self.client.post(self.media_upload_url, data, format="multipart")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(response.data["success"])

    def test_media_lifecycle_api_update_disable_restore(self):
        file = self._create_test_image("ad.png")
        media = CampaignMedia.objects.create(
            campaign=self.campaign,
            uploaded_by=self.owner,
            media_type=MediaType.IMAGE,
            file=file,
            title="Initial Title",
            file_size=500,
            mime_type="image/png",
            status=MediaStatus.READY,
        )

        detail_url = reverse("campaigns:campaign-media-detail", kwargs={"pk": media.id})
        restore_url = reverse("campaigns:campaign-media-restore", kwargs={"pk": media.id})

        # 1. Update metadata
        self.client.force_authenticate(user=self.owner)
        patch_res = self.client.patch(detail_url, {"title": "Updated Title via API"}, format="json")
        self.assertEqual(patch_res.status_code, status.HTTP_200_OK)
        media.refresh_from_db()
        self.assertEqual(media.title, "Updated Title via API")

        # 2. Disable media (DELETE)
        del_res = self.client.delete(detail_url)
        self.assertEqual(del_res.status_code, status.HTTP_200_OK)
        media.refresh_from_db()
        self.assertEqual(media.status, MediaStatus.DISABLED)

        # 3. Restore media (POST restore)
        restore_res = self.client.post(restore_url)
        self.assertEqual(restore_res.status_code, status.HTTP_200_OK)
        media.refresh_from_db()
        self.assertEqual(media.status, MediaStatus.READY)

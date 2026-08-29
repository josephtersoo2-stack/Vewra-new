import io
from decimal import Decimal
from PIL import Image
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.core.exceptions import PermissionDenied

from apps.campaigns.models import Campaign, CampaignType, CampaignStatus, CampaignMedia, MediaType, MediaStatus
from apps.campaigns.services import CampaignMediaService

User = get_user_model()


class MediaPermissionsTest(TestCase):
    def setUp(self):
        # Advertiser A
        self.advertiser_a = User.objects.create_user(
            email="adv_a@test.com",
            username="adv_a",
            password="Password123!",
        )
        self.advertiser_a.role = "advertiser"
        self.advertiser_a.save()

        # Advertiser B
        self.advertiser_b = User.objects.create_user(
            email="adv_b@test.com",
            username="adv_b",
            password="Password123!",
        )
        self.advertiser_b.role = "advertiser"
        self.advertiser_b.save()

        # Normal User (Earner)
        self.normal_user = User.objects.create_user(
            email="normal_user@test.com",
            username="normal_user",
            password="Password123!",
        )

        # Admin
        self.admin = User.objects.create_superuser(
            email="admin_media@test.com",
            username="admin_media",
            password="Password123!",
        )

        # Campaign owned by Advertiser A
        self.campaign_a = Campaign.objects.create(
            owner=self.advertiser_a,
            campaign_type=CampaignType.ADVERTISEMENT,
            title="Advertiser A Campaign",
            budget=Decimal("500.00"),
            status=CampaignStatus.ACTIVE,
        )

    def _create_dummy_image(self):
        img = Image.new("RGB", (100, 100), color=(100, 150, 200))
        byte_arr = io.BytesIO()
        img.save(byte_arr, format="PNG")
        byte_arr.seek(0)
        return SimpleUploadedFile("test.png", byte_arr.read(), content_type="image/png")

    def test_normal_user_cannot_upload_media(self):
        file = self._create_dummy_image()
        with self.assertRaises(PermissionDenied):
            CampaignMediaService.create_media(
                campaign=self.campaign_a,
                uploaded_by=self.normal_user,
                file=file,
                media_type=MediaType.IMAGE,
                title="Normal User Attempt",
            )

    def test_advertiser_b_cannot_upload_to_advertiser_a_campaign(self):
        file = self._create_dummy_image()
        with self.assertRaises(PermissionDenied):
            CampaignMediaService.create_media(
                campaign=self.campaign_a,
                uploaded_by=self.advertiser_b,
                file=file,
                media_type=MediaType.IMAGE,
                title="Cross-tenant Upload Attempt",
            )

    def test_advertiser_a_can_upload_to_own_campaign(self):
        file = self._create_dummy_image()
        media = CampaignMediaService.create_media(
            campaign=self.campaign_a,
            uploaded_by=self.advertiser_a,
            file=file,
            media_type=MediaType.IMAGE,
            title="Valid Creative",
        )
        self.assertEqual(media.uploaded_by, self.advertiser_a)
        self.assertEqual(media.campaign, self.campaign_a)

    def test_admin_can_upload_to_any_campaign(self):
        file = self._create_dummy_image()
        media = CampaignMediaService.create_media(
            campaign=self.campaign_a,
            uploaded_by=self.admin,
            file=file,
            media_type=MediaType.IMAGE,
            title="Admin Creative",
        )
        self.assertEqual(media.uploaded_by, self.admin)

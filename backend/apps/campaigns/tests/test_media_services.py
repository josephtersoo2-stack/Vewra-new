import io
from decimal import Decimal
from PIL import Image
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.core.exceptions import ValidationError, PermissionDenied

from apps.campaigns.models import Campaign, CampaignType, CampaignStatus, CampaignMedia, MediaType, MediaStatus
from apps.campaigns.services import CampaignMediaService
from apps.campaigns.media_services import MediaValidationService

User = get_user_model()


class MediaServicesTest(TestCase):
    def setUp(self):
        self.owner = User.objects.create_user(
            email="adv_owner@test.com",
            username="adv_owner",
            password="Password123!",
        )
        self.owner.role = "advertiser"
        self.owner.save()

        self.other_owner = User.objects.create_user(
            email="other_adv@test.com",
            username="other_adv",
            password="Password123!",
        )
        self.other_owner.role = "advertiser"
        self.other_owner.save()

        self.campaign = Campaign.objects.create(
            owner=self.owner,
            campaign_type=CampaignType.ADVERTISEMENT,
            title="Summer Ads 2026",
            budget=Decimal("1000.00"),
            status=CampaignStatus.ACTIVE,
        )

    def _create_test_image_file(self, filename="banner.png", width=300, height=250):
        img = Image.new("RGB", (width, height), color=(73, 109, 137))
        byte_arr = io.BytesIO()
        img.save(byte_arr, format="PNG")
        byte_arr.seek(0)
        return SimpleUploadedFile(filename, byte_arr.read(), content_type="image/png")

    def test_media_validation_valid_image(self):
        image_file = self._create_test_image_file("ad.png", 600, 400)
        result = MediaValidationService.validate_and_inspect_file(image_file, MediaType.IMAGE)
        self.assertEqual(result["width"], 600)
        self.assertEqual(result["height"], 400)
        self.assertEqual(result["mime_type"], "image/png")
        self.assertGreater(result["file_size"], 0)

    def test_media_validation_disallowed_extension(self):
        script_file = SimpleUploadedFile("malicious.php", b"<?php echo 'hack'; ?>", content_type="application/x-php")
        with self.assertRaises(ValidationError):
            MediaValidationService.validate_and_inspect_file(script_file, MediaType.IMAGE)

    def test_media_validation_invalid_video_extension(self):
        avi_file = SimpleUploadedFile("video.avi", b"fake video content", content_type="video/avi")
        with self.assertRaises(ValidationError):
            MediaValidationService.validate_and_inspect_file(avi_file, MediaType.VIDEO)

    def test_campaign_media_service_create_and_lifecycle(self):
        image_file = self._create_test_image_file("hero.png", 728, 90)
        media = CampaignMediaService.create_media(
            campaign=self.campaign,
            uploaded_by=self.owner,
            file=image_file,
            media_type=MediaType.BANNER,
            title="Top Leaderboard Banner",
            description="High visibility header asset",
        )

        self.assertEqual(media.status, MediaStatus.READY)
        self.assertEqual(media.width, 728)
        self.assertEqual(media.height, 90)
        self.assertEqual(media.media_type, MediaType.BANNER)

        # Update metadata
        updated = CampaignMediaService.update_media(media, self.owner, title="Updated Header Banner")
        self.assertEqual(updated.title, "Updated Header Banner")

        # Disable (soft-delete)
        disabled = CampaignMediaService.disable_media(media, self.owner)
        self.assertEqual(disabled.status, MediaStatus.DISABLED)

        # Restore
        restored = CampaignMediaService.restore_media(media, self.owner)
        self.assertEqual(restored.status, MediaStatus.READY)

    def test_other_advertiser_cannot_modify_media(self):
        image_file = self._create_test_image_file("hero.png")
        media = CampaignMediaService.create_media(
            campaign=self.campaign,
            uploaded_by=self.owner,
            file=image_file,
            media_type=MediaType.IMAGE,
            title="Exclusive Creative",
        )

        with self.assertRaises(PermissionDenied):
            CampaignMediaService.update_media(media, self.other_owner, title="Hacked Title")

        with self.assertRaises(PermissionDenied):
            CampaignMediaService.disable_media(media, self.other_owner)

import uuid
from decimal import Decimal
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from apps.campaigns.models import Campaign, CampaignType, CampaignStatus, CampaignMedia, MediaType, MediaStatus

User = get_user_model()


class CampaignMediaModelTest(TestCase):
    def setUp(self):
        self.owner = User.objects.create_user(
            email="media_owner@test.com",
            username="media_owner",
            password="Password123!",
        )
        self.campaign = Campaign.objects.create(
            owner=self.owner,
            campaign_type=CampaignType.ADVERTISEMENT,
            title="Promo Campaign",
            budget=Decimal("500.00"),
            status=CampaignStatus.DRAFT,
        )

    def test_create_campaign_media_model(self):
        dummy_file = SimpleUploadedFile("banner.png", b"dummy_png_bytes", content_type="image/png")
        media = CampaignMedia.objects.create(
            campaign=self.campaign,
            uploaded_by=self.owner,
            media_type=MediaType.BANNER,
            file=dummy_file,
            title="Homepage 728x90 Banner",
            description="High-converting banner",
            file_size=1024,
            mime_type="image/png",
            width=728,
            height=90,
            status=MediaStatus.READY,
        )

        self.assertIsInstance(media.id, uuid.UUID)
        self.assertEqual(media.campaign, self.campaign)
        self.assertEqual(media.uploaded_by, self.owner)
        self.assertEqual(media.media_type, MediaType.BANNER)
        self.assertEqual(media.title, "Homepage 728x90 Banner")
        self.assertEqual(media.status, MediaStatus.READY)
        self.assertEqual(media.width, 728)
        self.assertEqual(media.height, 90)
        self.assertIn("Banner Asset", str(media))

    def test_media_relationship_cascade(self):
        dummy_file = SimpleUploadedFile("test.png", b"content", content_type="image/png")
        CampaignMedia.objects.create(
            campaign=self.campaign,
            uploaded_by=self.owner,
            media_type=MediaType.IMAGE,
            file=dummy_file,
            title="Promo Image",
        )
        self.assertEqual(self.campaign.media.count(), 1)
        self.campaign.delete()
        self.assertEqual(CampaignMedia.objects.count(), 0)

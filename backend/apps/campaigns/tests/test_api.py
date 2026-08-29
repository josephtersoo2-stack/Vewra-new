from decimal import Decimal
from django.urls import reverse
from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase
from rest_framework import status
from apps.campaigns.models import Campaign, CampaignType, CampaignStatus

User = get_user_model()


class CampaignAPITest(APITestCase):
    def setUp(self):
        self.owner = User.objects.create_user(
            email="owner@test.com",
            username="owner_api",
            password="Password123!",
        )
        self.other_user = User.objects.create_user(
            email="other@test.com",
            username="other_api",
            password="Password123!",
        )
        self.admin = User.objects.create_superuser(
            email="admin@test.com",
            username="admin_api",
            password="Password123!",
        )
        self.list_create_url = reverse("campaigns:campaign-list")

    def test_create_campaign_api(self):
        self.client.force_authenticate(user=self.owner)
        payload = {
            "title": "Samsung S24 Promo",
            "campaign_type": CampaignType.ADVERTISEMENT,
            "description": "Product launch campaign",
            "budget": "2500.00",
        }
        response = self.client.post(self.list_create_url, payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["status"], CampaignStatus.DRAFT)
        self.assertEqual(response.data["campaign"]["title"], "Samsung S24 Promo")

    def test_list_campaigns_with_filters(self):
        # Create campaigns
        Campaign.objects.create(
            owner=self.owner,
            title="Draft Task",
            campaign_type=CampaignType.TASK,
            status=CampaignStatus.DRAFT,
        )
        Campaign.objects.create(
            owner=self.other_user,
            title="Active Ad",
            campaign_type=CampaignType.ADVERTISEMENT,
            status=CampaignStatus.ACTIVE,
        )

        self.client.force_authenticate(user=self.owner)
        # Owner sees own draft and public active
        response = self.client.get(self.list_create_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 2)

        # Filter by status=ACTIVE
        response_active = self.client.get(f"{self.list_create_url}?status=ACTIVE")
        self.assertEqual(response_active.status_code, status.HTTP_200_OK)
        self.assertEqual(response_active.data["count"], 1)

        # Filter by type=TASK
        response_task = self.client.get(f"{self.list_create_url}?type=TASK")
        self.assertEqual(response_task.status_code, status.HTTP_200_OK)
        self.assertEqual(response_task.data["count"], 1)

    def test_campaign_detail_and_state_transitions(self):
        campaign = Campaign.objects.create(
            owner=self.owner,
            title="Lifecycle Test",
            campaign_type=CampaignType.TASK,
            status=CampaignStatus.DRAFT,
        )
        detail_url = reverse("campaigns:campaign-detail", kwargs={"pk": campaign.id})
        submit_url = reverse("campaigns:campaign-submit-review", kwargs={"pk": campaign.id})
        approve_url = reverse("campaigns:campaign-approve", kwargs={"pk": campaign.id})
        pause_url = reverse("campaigns:campaign-pause", kwargs={"pk": campaign.id})

        # 1. Detail view
        self.client.force_authenticate(user=self.owner)
        detail_res = self.client.get(detail_url)
        self.assertEqual(detail_res.status_code, status.HTTP_200_OK)

        # 2. Submit for review
        submit_res = self.client.post(submit_url)
        self.assertEqual(submit_res.status_code, status.HTTP_200_OK)
        campaign.refresh_from_db()
        self.assertEqual(campaign.status, CampaignStatus.PENDING_REVIEW)

        # 3. Approve as admin
        self.client.force_authenticate(user=self.admin)
        approve_res = self.client.post(approve_url)
        self.assertEqual(approve_res.status_code, status.HTTP_200_OK)
        campaign.refresh_from_db()
        self.assertEqual(campaign.status, CampaignStatus.ACTIVE)

        # 4. Pause as owner
        self.client.force_authenticate(user=self.owner)
        pause_res = self.client.post(pause_url)
        self.assertEqual(pause_res.status_code, status.HTTP_200_OK)
        campaign.refresh_from_db()
        self.assertEqual(campaign.status, CampaignStatus.PAUSED)

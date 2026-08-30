from decimal import Decimal
from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth import get_user_model
from django.urls import reverse

from apps.campaigns.models import Campaign, CampaignType, CampaignStatus
from apps.advertising.billing.models import (
    AdvertiserWallet,
    CampaignBudget,
    AdvertisementCharge,
    ChargeEventType,
)
from apps.advertising.billing.services import AdvertiserBillingService

User = get_user_model()


class BillingAPITests(APITestCase):
    def setUp(self):
        self.advertiser = User.objects.create_user(
            username="api_advertiser",
            email="api_adv@example.com",
            password="StrongPassword123!",
        )
        self.advertiser.role = "advertiser"
        self.advertiser.is_advertiser = True
        self.advertiser.save()

        self.campaign = Campaign.objects.create(
            owner=self.advertiser,
            title="API Tracked Campaign",
            campaign_type=CampaignType.ADVERTISEMENT,
            budget=Decimal("150.00"),
            status=CampaignStatus.ACTIVE,
        )
        self.budget = AdvertiserBillingService.get_or_create_budget(
            campaign=self.campaign,
            total_budget=Decimal("150.00"),
            cpm_rate=Decimal("3.00"),
            cpc_rate=Decimal("0.12"),
        )
        self.wallet = AdvertiserBillingService.fund_wallet(self.advertiser, Decimal("200.00"))

    def test_get_advertiser_wallet_api(self):
        self.client.force_authenticate(user=self.advertiser)
        url = reverse("advertiser-wallet")
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(float(response.data["balance"]), 200.0)
        self.assertEqual(response.data["currency"], "USD")

    def test_fund_advertiser_wallet_api(self):
        self.client.force_authenticate(user=self.advertiser)
        url = reverse("advertiser-wallet-fund")
        response = self.client.post(url, {"amount": "50.00"}, format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(float(response.data["wallet"]["balance"]), 250.0)

    def test_get_billing_history_api(self):
        # Create charge
        AdvertisementCharge.objects.create(
            advertiser=self.advertiser,
            campaign=self.campaign,
            event_type=ChargeEventType.CLICK,
            amount=Decimal("0.12"),
            reference_id="ref-click-999",
        )

        self.client.force_authenticate(user=self.advertiser)
        url = reverse("advertiser-billing-history")
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 1)
        self.assertEqual(response.data["charges"][0]["reference_id"], "ref-click-999")

    def test_get_campaign_spending_api(self):
        self.client.force_authenticate(user=self.advertiser)
        url = reverse("campaigns:campaign-spending", kwargs={"campaign_id": str(self.campaign.id)})
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["campaign_id"], str(self.campaign.id))
        self.assertEqual(response.data["total_budget"], 150.0)
        self.assertEqual(response.data["cpm_rate"], 3.0)

    def test_configure_campaign_budget_api(self):
        self.client.force_authenticate(user=self.advertiser)
        url = reverse("campaigns:campaign-budget-configure", kwargs={"campaign_id": str(self.campaign.id)})
        payload = {
            "daily_budget": "25.00",
            "total_budget": "300.00",
            "cpm_rate": "4.00",
            "cpc_rate": "0.20",
        }
        response = self.client.post(url, payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(float(response.data["budget"]["total_budget"]), 300.0)
        self.assertEqual(float(response.data["budget"]["daily_budget"]), 25.0)

    def test_get_advertiser_reports_api(self):
        self.client.force_authenticate(user=self.advertiser)
        url = reverse("advertiser-reports")
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("campaigns", response.data)
        self.assertIn("wallet_balance", response.data)

    def test_export_advertiser_reports_csv_api(self):
        self.client.force_authenticate(user=self.advertiser)
        url = reverse("advertiser-reports-export")
        response = self.client.get(f"{url}?format=csv")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response["Content-Type"], "text/csv")
        self.assertIn("Campaign Name", response.content.decode("utf-8"))

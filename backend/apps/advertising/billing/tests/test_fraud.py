from django.test import TestCase
from django.contrib.auth import get_user_model
from apps.campaigns.models import Campaign, CampaignType, CampaignStatus
from apps.advertising.billing.models import (
    ChargeEventType,
    FraudRiskLevel,
    AdvertisementFraudLog,
    AdvertisementCharge,
)
from apps.advertising.billing.fraud import FraudScoreService

User = get_user_model()


class FraudProtectionTests(TestCase):
    def setUp(self):
        self.advertiser = User.objects.create_user(
            username="fraud_test_advertiser",
            email="fraud_adv@example.com",
            password="StrongPassword123!",
        )
        self.advertiser.role = "advertiser"
        self.advertiser.is_advertiser = True

        self.campaign = Campaign.objects.create(
            owner=self.advertiser,
            title="Fraud Monitored Campaign",
            campaign_type=CampaignType.ADVERTISEMENT,
            status=CampaignStatus.ACTIVE,
        )

    def test_normal_engagement_low_risk(self):
        result = FraudScoreService.evaluate_engagement(
            campaign=self.campaign,
            event_type=ChargeEventType.CLICK,
            session_id="normal-session-001",
            ip_address="203.0.113.195",
        )

        self.assertEqual(result["risk_level"], FraudRiskLevel.LOW)
        self.assertFalse(result["is_blocked"])
        self.assertEqual(result["fraud_score"], 0)
        self.assertEqual(AdvertisementFraudLog.objects.count(), 0)

    def test_suspicious_video_duration_detection(self):
        # 30 second video with < 2 seconds watched marked as completed
        result = FraudScoreService.evaluate_engagement(
            campaign=self.campaign,
            event_type=ChargeEventType.VIDEO_COMPLETION,
            session_id="bot-session-002",
            ip_address="203.0.113.196",
            watched_seconds=1.2,
            video_duration=30.0,
        )

        self.assertEqual(result["risk_level"], FraudRiskLevel.HIGH)
        self.assertTrue(result["is_blocked"])
        self.assertTrue(result["fraud_score"] >= 70)
        self.assertEqual(AdvertisementFraudLog.objects.count(), 1)

        log = AdvertisementFraudLog.objects.first()
        self.assertEqual(log.risk_level, FraudRiskLevel.HIGH)
        self.assertTrue(log.is_blocked)
        self.assertIn("short watch duration", log.flag_reason)

    def test_excessive_click_frequency_detection(self):
        # Create 5 rapid clicks from same session
        for i in range(5):
            AdvertisementCharge.objects.create(
                advertiser=self.advertiser,
                campaign=self.campaign,
                event_type=ChargeEventType.CLICK,
                amount=0.10,
                reference_id=f"click-repeat-session-003-{i}",
            )

        result = FraudScoreService.evaluate_engagement(
            campaign=self.campaign,
            event_type=ChargeEventType.CLICK,
            session_id="session-003",
        )

        self.assertEqual(result["risk_level"], FraudRiskLevel.HIGH)
        self.assertTrue(result["is_blocked"])
        self.assertTrue(result["fraud_score"] >= 70)

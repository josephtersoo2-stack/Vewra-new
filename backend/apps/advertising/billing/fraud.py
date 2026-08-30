import hashlib
from datetime import timedelta
from django.utils import timezone
from django.db.models import Count
from apps.advertising.billing.models import (
    AdvertisementFraudLog,
    FraudRiskLevel,
    ChargeEventType,
    AdvertisementCharge,
)
from apps.campaigns.models import Campaign


class FraudScoreService:
    """
    Engine evaluating advertisement engagement telemetry for suspicious patterns,
    click-fraud, and bot abuse to safeguard advertiser budgets.
    """

    @classmethod
    def evaluate_engagement(
        cls,
        campaign: Campaign,
        event_type: str,
        session_id: str = "",
        ip_address: str = "",
        device_id: str = "",
        user=None,
        watched_seconds: float = 0.0,
        video_duration: float = 0.0,
    ) -> dict:
        score = 0
        reasons = []

        ip_hash = ""
        if ip_address:
            ip_hash = hashlib.sha256(ip_address.encode("utf-8")).hexdigest()

        now = timezone.now()
        one_minute_ago = now - timedelta(minutes=1)
        ten_minutes_ago = now - timedelta(minutes=10)

        # 1. Suspicious click frequency check
        if event_type == ChargeEventType.CLICK:
            recent_clicks_count = 0
            if session_id:
                recent_clicks_count = AdvertisementCharge.objects.filter(
                    campaign=campaign,
                    event_type=ChargeEventType.CLICK,
                    reference_id__contains=session_id,
                    created_at__gte=one_minute_ago,
                ).count()

            if recent_clicks_count >= 5:
                score += 75
                reasons.append(f"Excessive click frequency ({recent_clicks_count} clicks in 1 min)")
            elif recent_clicks_count >= 2:
                score += 35
                reasons.append("Multiple rapid clicks detected")

        # 2. Suspicious video viewing check
        if event_type == ChargeEventType.VIDEO_COMPLETION:
            if video_duration > 0 and watched_seconds < 2.0:
                score += 80
                reasons.append("Unrealistically short watch duration for completion")
            elif video_duration > 0 and watched_seconds < (video_duration * 0.90):
                score += 45
                reasons.append("Watched seconds below 90% threshold for completion billing")

        # 3. Known fraud history check
        if ip_hash:
            past_fraud_count = AdvertisementFraudLog.objects.filter(
                ip_hash=ip_hash,
                risk_level=FraudRiskLevel.HIGH,
                created_at__gte=ten_minutes_ago,
            ).count()
            if past_fraud_count > 0:
                score += 40
                reasons.append("Recent high-risk activity recorded from this IP signature")

        # Cap score between 0 and 100
        score = min(100, max(0, score))

        if score >= 70:
            risk_level = FraudRiskLevel.HIGH
            is_blocked = True
        elif score >= 40:
            risk_level = FraudRiskLevel.MEDIUM
            is_blocked = False
        else:
            risk_level = FraudRiskLevel.LOW
            is_blocked = False

        flag_reason = "; ".join(reasons) if reasons else "Normal verified activity"

        # If suspicious or high risk, persist audit log
        if risk_level in (FraudRiskLevel.MEDIUM, FraudRiskLevel.HIGH):
            AdvertisementFraudLog.objects.create(
                advertiser=getattr(campaign, "owner", None),
                campaign=campaign,
                event_type=event_type,
                fraud_score=score,
                risk_level=risk_level,
                flag_reason=flag_reason,
                ip_hash=ip_hash,
                session_id=session_id,
                device_id=device_id,
                is_blocked=is_blocked,
            )

        return {
            "fraud_score": score,
            "risk_level": risk_level,
            "is_blocked": is_blocked,
            "flag_reason": flag_reason,
        }

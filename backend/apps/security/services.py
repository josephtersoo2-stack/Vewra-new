from django.utils import timezone
from .models import (
    Verification,
    TrustScoreHistory,
    DeviceSecurity,
    VerificationLevel,
    VerificationStatus,
)

class SecurityService:
    @staticmethod
    def get_or_create_verification(user):
        verification, _ = Verification.objects.get_or_create(
            user=user,
            defaults={
                'verification_level': VerificationLevel.BASIC,
                'status': VerificationStatus.NOT_STARTED,
                'document_status': 'BASIC',
                'country': user.country or 'Global',
            }
        )
        return verification

    @staticmethod
    def submit_verification(user, country, document_type, document_reference):
        verification = SecurityService.get_or_create_verification(user)
        verification.country = country
        verification.document_type = document_type
        verification.document_reference = document_reference
        verification.status = VerificationStatus.PENDING
        verification.document_status = 'PENDING'
        verification.submitted_at = timezone.now()
        verification.save()

        # Update user profile verification status to Pending Review
        if hasattr(user, 'profile'):
            user.profile.verification_status = 'Pending Review'
            user.profile.save()

        return verification

    @staticmethod
    def record_trust_score_change(user, new_score, reason):
        previous_score = 75
        if hasattr(user, 'profile'):
            previous_score = user.profile.trust_score
            user.profile.trust_score = new_score
            user.profile.save()

        history = TrustScoreHistory.objects.create(
            user=user,
            previous_score=previous_score,
            new_score=new_score,
            reason=reason,
        )
        return history

    @staticmethod
    def register_or_update_device(user, device_id, platform='android', app_version='1.0.0', is_vpn=False, is_rooted=False):
        device, created = DeviceSecurity.objects.update_or_create(
            user=user,
            device_id=device_id,
            defaults={
                'platform': platform,
                'app_version': app_version,
                'is_vpn_detected': is_vpn,
                'is_rooted': is_rooted,
            }
        )
        return device

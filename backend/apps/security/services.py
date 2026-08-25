from .models import Verification, DeviceSecurity, VerificationLevel, DocumentStatus

class SecurityService:
    @staticmethod
    def get_or_create_verification(user):
        verification, _ = Verification.objects.get_or_create(
            user=user,
            defaults={
                'verification_level': VerificationLevel.BASIC,
                'document_status': DocumentStatus.BASIC,
            }
        )
        return verification

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

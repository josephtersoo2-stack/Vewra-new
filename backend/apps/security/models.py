from django.db import models
from django.conf import settings

class VerificationLevel(models.TextChoices):
    BASIC = 'BASIC', 'Basic User'
    VERIFIED = 'VERIFIED', 'Verified User'
    TRUSTED = 'TRUSTED', 'Trusted User'

class DocumentStatus(models.TextChoices):
    BASIC = 'BASIC', 'Basic'
    PENDING = 'PENDING', 'Pending Review'
    VERIFIED = 'VERIFIED', 'Verified'
    REJECTED = 'REJECTED', 'Rejected'

class Verification(models.Model):
    """User identity and KYC verification record."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='verifications'
    )
    verification_level = models.CharField(
        max_length=20,
        choices=VerificationLevel.choices,
        default=VerificationLevel.BASIC
    )
    document_status = models.CharField(
        max_length=20,
        choices=DocumentStatus.choices,
        default=DocumentStatus.BASIC
    )
    verified_at = models.DateTimeField(null=True, blank=True)
    reviewed_by = models.CharField(max_length=100, blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_verifications'
        verbose_name = 'Verification'
        verbose_name_plural = 'Verifications'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} - {self.verification_level} ({self.document_status})"


class DeviceSecurity(models.Model):
    """Registered user device security record for fraud prevention."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='devices'
    )
    device_id = models.CharField(max_length=128, db_index=True)
    platform = models.CharField(max_length=50, default='android')
    app_version = models.CharField(max_length=20, default='1.0.0')
    is_trusted = models.BooleanField(default=True)
    is_vpn_detected = models.BooleanField(default=False)
    is_rooted = models.BooleanField(default=False)
    last_seen = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'vewra_device_security'
        verbose_name = 'Device Security'
        verbose_name_plural = 'Device Securities'
        unique_together = ('user', 'device_id')
        ordering = ['-last_seen']

    def __str__(self):
        return f"{self.user.username} - {self.platform} ({self.device_id[:8]}...)"

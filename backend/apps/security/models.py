from django.db import models
from django.conf import settings

class VerificationLevel(models.TextChoices):
    BASIC = 'BASIC', 'Basic User'
    VERIFIED = 'VERIFIED', 'Verified User'
    TRUSTED = 'TRUSTED', 'Trusted User'

class VerificationStatus(models.TextChoices):
    NOT_STARTED = 'NOT_STARTED', 'Not Started'
    PENDING = 'PENDING', 'Pending Review'
    APPROVED = 'APPROVED', 'Approved'
    REJECTED = 'REJECTED', 'Rejected'

class DocumentType(models.TextChoices):
    NATIONAL_ID = 'NATIONAL_ID', 'National ID Card'
    PASSPORT = 'PASSPORT', 'International Passport'
    DRIVERS_LICENSE = 'DRIVERS_LICENSE', "Driver's License"
    UTILITY_BILL = 'UTILITY_BILL', 'Utility Bill'
    OTHER = 'OTHER', 'Other Official ID'

class Verification(models.Model):
    """User identity and KYC verification record."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='verifications'
    )
    country = models.CharField(max_length=100, default='Global')
    verification_level = models.CharField(
        max_length=20,
        choices=VerificationLevel.choices,
        default=VerificationLevel.BASIC
    )
    status = models.CharField(
        max_length=20,
        choices=VerificationStatus.choices,
        default=VerificationStatus.NOT_STARTED
    )
    # Legacy alias support
    document_status = models.CharField(
        max_length=20,
        default='BASIC'
    )
    document_type = models.CharField(
        max_length=30,
        choices=DocumentType.choices,
        default=DocumentType.NATIONAL_ID
    )
    document_reference = models.CharField(max_length=100, blank=True, default='')
    submitted_at = models.DateTimeField(null=True, blank=True)
    reviewed_at = models.DateTimeField(null=True, blank=True)
    approved_at = models.DateTimeField(null=True, blank=True)
    verified_at = models.DateTimeField(null=True, blank=True)
    reviewed_by = models.CharField(max_length=100, blank=True, null=True)
    rejection_reason = models.TextField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_verifications'
        verbose_name = 'Verification'
        verbose_name_plural = 'Verifications'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} - {self.verification_level} ({self.status})"


class TrustScoreHistory(models.Model):
    """Audit ledger tracking trust score changes."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='trust_history'
    )
    previous_score = models.PositiveIntegerField()
    new_score = models.PositiveIntegerField()
    reason = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'vewra_trust_score_history'
        verbose_name = 'Trust Score History'
        verbose_name_plural = 'Trust Score Histories'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username}: {self.previous_score} -> {self.new_score} ({self.reason})"


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

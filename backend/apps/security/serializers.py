from rest_framework import serializers
from .models import Verification, TrustScoreHistory, DeviceSecurity, DocumentType

class VerificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Verification
        fields = (
            'id',
            'country',
            'verification_level',
            'status',
            'document_status',
            'document_type',
            'document_reference',
            'submitted_at',
            'reviewed_at',
            'approved_at',
            'verified_at',
            'rejection_reason',
            'created_at',
        )
        read_only_fields = (
            'id',
            'verification_level',
            'status',
            'document_status',
            'submitted_at',
            'reviewed_at',
            'approved_at',
            'verified_at',
            'rejection_reason',
            'created_at',
        )


class VerificationSubmitSerializer(serializers.Serializer):
    country = serializers.CharField(required=True, max_length=100)
    document_type = serializers.ChoiceField(choices=DocumentType.choices, default=DocumentType.NATIONAL_ID)
    document_reference = serializers.CharField(required=True, max_length=100)


class TrustScoreHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = TrustScoreHistory
        fields = (
            'id',
            'previous_score',
            'new_score',
            'reason',
            'created_at',
        )
        read_only_fields = fields


class DeviceSecuritySerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceSecurity
        fields = (
            'device_id',
            'platform',
            'app_version',
            'is_trusted',
            'is_vpn_detected',
            'is_rooted',
            'last_seen',
        )
        read_only_fields = ('is_trusted', 'last_seen')

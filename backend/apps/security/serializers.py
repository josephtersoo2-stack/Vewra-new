from rest_framework import serializers
from .models import Verification, DeviceSecurity

class VerificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Verification
        fields = (
            'id',
            'verification_level',
            'document_status',
            'verified_at',
            'reviewed_by',
            'notes',
            'created_at',
        )
        read_only_fields = ('id', 'verified_at', 'reviewed_by', 'created_at')


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

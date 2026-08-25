from django.contrib import admin
from .models import Verification, DeviceSecurity

@admin.register(Verification)
class VerificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'verification_level', 'document_status', 'verified_at', 'created_at')
    list_filter = ('verification_level', 'document_status')
    search_fields = ('user__username', 'user__email', 'reviewed_by')

@admin.register(DeviceSecurity)
class DeviceSecurityAdmin(admin.ModelAdmin):
    list_display = ('user', 'device_id', 'platform', 'app_version', 'is_trusted', 'is_vpn_detected', 'last_seen')
    list_filter = ('platform', 'is_trusted', 'is_vpn_detected', 'is_rooted')
    search_fields = ('user__username', 'device_id')

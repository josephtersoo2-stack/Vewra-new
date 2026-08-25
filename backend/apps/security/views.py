from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from .serializers import VerificationSerializer, DeviceSecuritySerializer
from .services import SecurityService

class VerificationStatusView(APIView):
    """API endpoint to get user's verification level and document status."""

    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        verification = SecurityService.get_or_create_verification(request.user)
        serializer = VerificationSerializer(verification)
        return Response(
            {
                'status': 'success',
                'verification': serializer.data,
            },
            status=status.HTTP_200_OK
        )


class DeviceRegisterView(APIView):
    """API endpoint to register/log active client device for security tracking."""

    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, *args, **kwargs):
        device_id = request.data.get('device_id')
        if not device_id:
            return Response(
                {
                    'status': 'error',
                    'message': 'device_id is required',
                },
                status=status.HTTP_400_BAD_REQUEST
            )

        platform = request.data.get('platform', 'android')
        app_version = request.data.get('app_version', '1.0.0')
        is_vpn = request.data.get('is_vpn_detected', False)
        is_rooted = request.data.get('is_rooted', False)

        device = SecurityService.register_or_update_device(
            user=request.user,
            device_id=device_id,
            platform=platform,
            app_version=app_version,
            is_vpn=is_vpn,
            is_rooted=is_rooted
        )
        serializer = DeviceSecuritySerializer(device)
        return Response(
            {
                'status': 'success',
                'device': serializer.data,
            },
            status=status.HTTP_200_OK
        )

from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from .serializers import (
    VerificationSerializer,
    VerificationSubmitSerializer,
    TrustScoreHistorySerializer,
    DeviceSecuritySerializer,
)
from .services import SecurityService
from .models import TrustScoreHistory

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


class VerificationSubmitView(APIView):
    """API endpoint to submit KYC verification documentation."""

    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, *args, **kwargs):
        serializer = VerificationSubmitSerializer(data=request.data)
        if serializer.is_valid():
            verification = SecurityService.submit_verification(
                user=request.user,
                country=serializer.validated_data['country'],
                document_type=serializer.validated_data['document_type'],
                document_reference=serializer.validated_data['document_reference'],
            )
            return Response(
                {
                    'status': 'success',
                    'message': 'Verification documents submitted successfully.',
                    'verification': VerificationSerializer(verification).data,
                },
                status=status.HTTP_200_OK
            )
        return Response(
            {
                'status': 'error',
                'errors': serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST
        )


class TrustScoreHistoryView(APIView):
    """API endpoint to fetch user's trust score historical changes."""

    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        history = TrustScoreHistory.objects.filter(user=request.user).order_by('-created_at')
        serializer = TrustScoreHistorySerializer(history, many=True)
        return Response(
            {
                'status': 'success',
                'history': serializer.data,
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

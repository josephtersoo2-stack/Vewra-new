from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from django.core.exceptions import ValidationError, PermissionDenied

from apps.campaigns.tracking.serializers import (
    ImpressionRecordSerializer,
    ClickRecordSerializer,
    VideoProgressRecordSerializer,
)
from apps.campaigns.tracking.services import AdvertisementTrackingService
from apps.campaigns.tracking.selectors import (
    get_campaign_analytics,
    get_advertiser_overview_analytics,
)
from apps.campaigns.tracking.permissions import (
    CanViewCampaignAnalytics,
    CanViewAdvertiserOverview,
)


def _get_client_ip(request):
    """Utility to extract client IP address."""
    x_forwarded_for = request.META.get("HTTP_X_FORWARDED_FOR")
    if x_forwarded_for:
        return x_forwarded_for.split(",")[0].strip()
    return request.META.get("REMOTE_ADDR", "")


class RecordImpressionView(APIView):
    """
    POST /api/v1/ads/impression/
    Records an advertisement impression event.
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = ImpressionRecordSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {"detail": "Validation error.", "errors": serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )

        ip_address = _get_client_ip(request)
        user_agent = request.META.get("HTTP_USER_AGENT", "")

        try:
            impression = AdvertisementTrackingService.record_impression(
                campaign_id=serializer.validated_data["campaign_id"],
                placement_id=serializer.validated_data["placement_id"],
                media_id=serializer.validated_data["media_id"],
                user=request.user if request.user.is_authenticated else None,
                session_id=serializer.validated_data.get("session_id", ""),
                device_id=serializer.validated_data.get("device_id"),
                ip_address=ip_address,
                user_agent=user_agent,
            )
            return Response(
                {
                    "success": True,
                    "impression_id": str(impression.id),
                    "created_at": impression.created_at.isoformat(),
                },
                status=status.HTTP_201_CREATED,
            )
        except ValidationError as e:
            return Response({"detail": str(e.message if hasattr(e, "message") else e)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({"detail": f"Failed to record impression: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class RecordClickView(APIView):
    """
    POST /api/v1/ads/click/
    Records an advertisement interaction or click event.
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = ClickRecordSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {"detail": "Validation error.", "errors": serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            click = AdvertisementTrackingService.record_click(
                campaign_id=serializer.validated_data["campaign_id"],
                media_id=serializer.validated_data["media_id"],
                impression_id=serializer.validated_data.get("impression_id"),
                user=request.user if request.user.is_authenticated else None,
                click_type=serializer.validated_data.get("click_type"),
                session_id=serializer.validated_data.get("session_id", ""),
            )
            return Response(
                {
                    "success": True,
                    "click_id": str(click.id),
                    "created_at": click.created_at.isoformat(),
                },
                status=status.HTTP_201_CREATED,
            )
        except ValidationError as e:
            return Response({"detail": str(e.message if hasattr(e, "message") else e)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({"detail": f"Failed to record click: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class RecordVideoProgressView(APIView):
    """
    POST /api/v1/ads/video-progress/
    Records playback duration and updates server-authoritative completion.
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = VideoProgressRecordSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {"detail": "Validation error.", "errors": serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            engagement = AdvertisementTrackingService.record_video_progress(
                campaign_id=serializer.validated_data["campaign_id"],
                media_id=serializer.validated_data["media_id"],
                session_id=serializer.validated_data["session_id"],
                watched_seconds=serializer.validated_data["watched_seconds"],
                user=request.user if request.user.is_authenticated else None,
            )
            return Response(
                {
                    "success": True,
                    "watched_seconds": engagement.watched_seconds,
                    "completion_percentage": engagement.completion_percentage,
                    "completed": engagement.completed,
                },
                status=status.HTTP_200_OK,
            )
        except ValidationError as e:
            return Response({"detail": str(e.message if hasattr(e, "message") else e)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({"detail": f"Failed to record video progress: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class CampaignAnalyticsView(APIView):
    """
    GET /api/v1/campaigns/{id}/analytics/
    Returns detailed measurement metrics for a campaign.
    """
    permission_classes = [permissions.IsAuthenticated, CanViewCampaignAnalytics]

    def get(self, request, campaign_id, *args, **kwargs):
        try:
            stats = get_campaign_analytics(campaign_id, user=request.user)
            return Response(stats, status=status.HTTP_200_OK)
        except ValidationError as e:
            return Response({"detail": str(e.message if hasattr(e, "message") else e)}, status=status.HTTP_400_BAD_REQUEST)
        except PermissionDenied as e:
            return Response({"detail": str(e)}, status=status.HTTP_403_FORBIDDEN)
        except Exception as e:
            return Response({"detail": f"Failed to fetch analytics: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class AdvertiserOverviewAnalyticsView(APIView):
    """
    GET /api/v1/advertiser/analytics/
    Returns high-level overview analytics for an advertiser or platform admin.
    """
    permission_classes = [permissions.IsAuthenticated, CanViewAdvertiserOverview]

    def get(self, request, *args, **kwargs):
        try:
            overview = get_advertiser_overview_analytics(request.user)
            return Response(overview, status=status.HTTP_200_OK)
        except PermissionDenied as e:
            return Response({"detail": str(e)}, status=status.HTTP_403_FORBIDDEN)
        except Exception as e:
            return Response({"detail": f"Failed to fetch overview analytics: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

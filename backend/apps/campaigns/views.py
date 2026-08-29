from rest_framework import status, views, permissions
from rest_framework.response import Response
from django.core.exceptions import ValidationError, PermissionDenied
from django.shortcuts import get_object_or_404

from .models import Campaign
from .serializers import (
    CampaignSerializer,
    CampaignCreateSerializer,
    CampaignStatusActionSerializer,
)
from .services import CampaignService
from .selectors import list_campaigns, get_campaign_by_id
from .permissions import IsCampaignOwner, IsAdminCampaignManager


class CampaignListCreateView(views.APIView):
    """
    GET /api/v1/campaigns/ - List campaigns with filtering.
    POST /api/v1/campaigns/ - Create a new campaign in DRAFT status.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        status_filter = request.query_params.get("status")
        type_filter = request.query_params.get("type") or request.query_params.get("campaign_type")
        search_query = request.query_params.get("search")
        is_admin = request.user.is_staff or getattr(request.user, "role", "") == "admin"

        qs = list_campaigns(
            user=request.user,
            status=status_filter,
            campaign_type=type_filter,
            search=search_query,
            is_admin=is_admin,
        )
        serializer = CampaignSerializer(qs, many=True)
        return Response({
            "success": True,
            "count": qs.count(),
            "campaigns": serializer.data,
            "results": serializer.data,  # Alias for standard pagination compatibility
        }, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = CampaignCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            campaign = CampaignService.create_campaign(
                owner=request.user,
                campaign_type=data["campaign_type"],
                title=data["title"],
                description=data.get("description", ""),
                budget=data.get("budget", 0),
                start_date=data.get("start_date"),
                end_date=data.get("end_date"),
            )
            out_serializer = CampaignSerializer(campaign)
            return Response({
                "success": True,
                "message": "Campaign created successfully in DRAFT status.",
                "campaign": out_serializer.data,
                "id": str(campaign.id),
                "status": campaign.status,
            }, status=status.HTTP_201_CREATED)
        except ValidationError as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class CampaignDetailView(views.APIView):
    """
    GET /api/v1/campaigns/<uuid:pk>/ - Retrieve campaign details.
    """
    permission_classes = [permissions.IsAuthenticated, IsCampaignOwner]

    def get(self, request, pk):
        campaign = get_object_or_404(Campaign.objects.select_related("owner"), pk=pk)
        self.check_object_permissions(request, campaign)
        serializer = CampaignSerializer(campaign)
        return Response({
            "success": True,
            "campaign": serializer.data,
        }, status=status.HTTP_200_OK)


class CampaignSubmitReviewView(views.APIView):
    """
    POST /api/v1/campaigns/<uuid:pk>/submit/ - Submit draft campaign for admin review.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        campaign = get_object_or_404(Campaign, pk=pk)
        try:
            updated = CampaignService.submit_for_review(campaign, request.user)
            return Response({
                "success": True,
                "message": "Campaign submitted for review.",
                "campaign": CampaignSerializer(updated).data,
            }, status=status.HTTP_200_OK)
        except PermissionDenied as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_403_FORBIDDEN)
        except ValidationError as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class CampaignApproveView(views.APIView):
    """
    POST /api/v1/campaigns/<uuid:pk>/approve/ - Admin approves campaign to ACTIVE.
    """
    permission_classes = [permissions.IsAuthenticated, IsAdminCampaignManager]

    def post(self, request, pk):
        campaign = get_object_or_404(Campaign, pk=pk)
        try:
            updated = CampaignService.approve_campaign(campaign, request.user)
            return Response({
                "success": True,
                "message": "Campaign approved and activated.",
                "campaign": CampaignSerializer(updated).data,
            }, status=status.HTTP_200_OK)
        except PermissionDenied as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_403_FORBIDDEN)
        except ValidationError as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class CampaignRejectView(views.APIView):
    """
    POST /api/v1/campaigns/<uuid:pk>/reject/ - Admin rejects campaign.
    """
    permission_classes = [permissions.IsAuthenticated, IsAdminCampaignManager]

    def post(self, request, pk):
        campaign = get_object_or_404(Campaign, pk=pk)
        serializer = CampaignStatusActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        reason = serializer.validated_data.get("reason", "")

        try:
            updated = CampaignService.reject_campaign(campaign, request.user, reason=reason)
            return Response({
                "success": True,
                "message": "Campaign rejected.",
                "campaign": CampaignSerializer(updated).data,
            }, status=status.HTTP_200_OK)
        except PermissionDenied as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_403_FORBIDDEN)
        except ValidationError as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class CampaignPauseView(views.APIView):
    """
    POST /api/v1/campaigns/<uuid:pk>/pause/ - Pause an active campaign.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        campaign = get_object_or_404(Campaign, pk=pk)
        try:
            updated = CampaignService.pause_campaign(campaign, request.user)
            return Response({
                "success": True,
                "message": "Campaign paused.",
                "campaign": CampaignSerializer(updated).data,
            }, status=status.HTTP_200_OK)
        except PermissionDenied as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_403_FORBIDDEN)
        except ValidationError as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

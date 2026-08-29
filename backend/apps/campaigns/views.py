from rest_framework import status, views, permissions
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from django.core.exceptions import ValidationError, PermissionDenied
from django.shortcuts import get_object_or_404

from .models import Campaign, CampaignMedia
from .serializers import (
    CampaignSerializer,
    CampaignCreateSerializer,
    CampaignStatusActionSerializer,
    CampaignMediaSerializer,
    CampaignMediaUploadSerializer,
    CampaignMediaUpdateSerializer,
)
from .services import CampaignService, CampaignMediaService
from .selectors import list_campaigns, get_campaign_by_id
from .permissions import (
    IsCampaignOwner,
    IsAdminCampaignManager,
    CanCreateCampaign,
    IsCampaignMediaOwnerOrAdmin,
)


class CampaignListCreateView(views.APIView):
    """
    GET /api/v1/campaigns/ - List campaigns with filtering.
    POST /api/v1/campaigns/ - Create a new campaign in DRAFT status (Advertiser / Admin only).
    """

    def get_permissions(self):
        if self.request.method == "POST":
            return [permissions.IsAuthenticated(), CanCreateCampaign()]
        return [permissions.IsAuthenticated()]

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
        serializer = CampaignSerializer(qs, many=True, context={"request": request})
        return Response({
            "success": True,
            "count": qs.count(),
            "campaigns": serializer.data,
            "results": serializer.data,
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
            return Response({
                "success": True,
                "status": campaign.status,
                "campaign": CampaignSerializer(campaign, context={"request": request}).data,
            }, status=status.HTTP_201_CREATED)
        except (ValidationError, PermissionDenied) as e:
            return Response({
                "success": False,
                "error": getattr(e, "message_dict", getattr(e, "message", str(e))),
            }, status=status.HTTP_400_BAD_REQUEST if isinstance(e, ValidationError) else status.HTTP_403_FORBIDDEN)


class CampaignDetailView(views.APIView):
    """
    GET /api/v1/campaigns/<uuid:pk>/ - Retrieve campaign details.
    """
    permission_classes = [permissions.IsAuthenticated, IsCampaignOwner]

    def get(self, request, pk):
        campaign = get_campaign_by_id(pk)
        if not campaign:
            return Response({"success": False, "error": "Campaign not found."}, status=status.HTTP_404_NOT_FOUND)

        self.check_object_permissions(request, campaign)
        return Response({
            "success": True,
            "campaign": CampaignSerializer(campaign, context={"request": request}).data,
        }, status=status.HTTP_200_OK)


class CampaignSubmitReviewView(views.APIView):
    """
    POST /api/v1/campaigns/<uuid:pk>/submit/ - Submit campaign for administrative review.
    """
    permission_classes = [permissions.IsAuthenticated, IsCampaignOwner]

    def post(self, request, pk):
        campaign = get_object_or_404(Campaign, pk=pk)
        self.check_object_permissions(request, campaign)

        try:
            updated = CampaignService.submit_for_review(campaign, request.user)
            return Response({
                "success": True,
                "status": updated.status,
                "campaign": CampaignSerializer(updated, context={"request": request}).data,
            }, status=status.HTTP_200_OK)
        except (ValidationError, PermissionDenied) as e:
            return Response({
                "success": False,
                "error": getattr(e, "message_dict", getattr(e, "message", str(e))),
            }, status=status.HTTP_400_BAD_REQUEST if isinstance(e, ValidationError) else status.HTTP_403_FORBIDDEN)


class CampaignApproveView(views.APIView):
    """
    POST /api/v1/campaigns/<uuid:pk>/approve/ - Approve pending campaign (Admin only).
    """
    permission_classes = [permissions.IsAuthenticated, IsAdminCampaignManager]

    def post(self, request, pk):
        campaign = get_object_or_404(Campaign, pk=pk)
        try:
            updated = CampaignService.approve_campaign(campaign, request.user)
            return Response({
                "success": True,
                "status": updated.status,
                "campaign": CampaignSerializer(updated, context={"request": request}).data,
            }, status=status.HTTP_200_OK)
        except (ValidationError, PermissionDenied) as e:
            return Response({
                "success": False,
                "error": getattr(e, "message_dict", getattr(e, "message", str(e))),
            }, status=status.HTTP_400_BAD_REQUEST if isinstance(e, ValidationError) else status.HTTP_403_FORBIDDEN)


class CampaignRejectView(views.APIView):
    """
    POST /api/v1/campaigns/<uuid:pk>/reject/ - Reject pending campaign (Admin only).
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
                "status": updated.status,
                "campaign": CampaignSerializer(updated, context={"request": request}).data,
            }, status=status.HTTP_200_OK)
        except (ValidationError, PermissionDenied) as e:
            return Response({
                "success": False,
                "error": getattr(e, "message_dict", getattr(e, "message", str(e))),
            }, status=status.HTTP_400_BAD_REQUEST if isinstance(e, ValidationError) else status.HTTP_403_FORBIDDEN)


class CampaignPauseView(views.APIView):
    """
    POST /api/v1/campaigns/<uuid:pk>/pause/ - Pause active campaign.
    """
    permission_classes = [permissions.IsAuthenticated, IsCampaignOwner]

    def post(self, request, pk):
        campaign = get_object_or_404(Campaign, pk=pk)
        self.check_object_permissions(request, campaign)

        try:
            updated = CampaignService.pause_campaign(campaign, request.user)
            return Response({
                "success": True,
                "status": updated.status,
                "campaign": CampaignSerializer(updated, context={"request": request}).data,
            }, status=status.HTTP_200_OK)
        except (ValidationError, PermissionDenied) as e:
            return Response({
                "success": False,
                "error": getattr(e, "message_dict", getattr(e, "message", str(e))),
            }, status=status.HTTP_400_BAD_REQUEST if isinstance(e, ValidationError) else status.HTTP_403_FORBIDDEN)


# ==============================================================================
# CAMPAIGN MEDIA VIEWS (STEP 2)
# ==============================================================================

class CampaignMediaListCreateView(views.APIView):
    """
    GET /api/v1/campaigns/<campaign_id>/media/ - List media assets for a campaign.
    POST /api/v1/campaigns/<campaign_id>/media/upload/ - Upload and attach a media asset.
    """
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get(self, request, campaign_id):
        campaign = get_object_or_404(Campaign, pk=campaign_id)
        media_type = request.query_params.get("type") or request.query_params.get("media_type")
        status_filter = request.query_params.get("status")

        try:
            qs = CampaignMediaService.list_campaign_media(
                campaign=campaign,
                user=request.user,
                media_type=media_type,
                status=status_filter,
            )
            serializer = CampaignMediaSerializer(qs, many=True, context={"request": request})
            return Response({
                "success": True,
                "count": qs.count(),
                "media": serializer.data,
                "results": serializer.data,
            }, status=status.HTTP_200_OK)
        except PermissionDenied as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_403_FORBIDDEN)

    def post(self, request, campaign_id):
        campaign = get_object_or_404(Campaign, pk=campaign_id)
        serializer = CampaignMediaUploadSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            media = CampaignMediaService.create_media(
                campaign=campaign,
                uploaded_by=request.user,
                file=data["file"],
                media_type=data["media_type"],
                title=data["title"],
                description=data.get("description", ""),
            )
            return Response({
                "success": True,
                "media": CampaignMediaSerializer(media, context={"request": request}).data,
            }, status=status.HTTP_201_CREATED)
        except (ValidationError, PermissionDenied) as e:
            return Response({
                "success": False,
                "error": getattr(e, "message_dict", getattr(e, "message", str(e))),
            }, status=status.HTTP_400_BAD_REQUEST if isinstance(e, ValidationError) else status.HTTP_403_FORBIDDEN)


class CampaignMediaDetailView(views.APIView):
    """
    GET /api/v1/campaign-media/<uuid:pk>/ - Retrieve media asset.
    PATCH /api/v1/campaign-media/<uuid:pk>/ - Update media metadata (title, description, status).
    DELETE /api/v1/campaign-media/<uuid:pk>/ - Soft-delete (disable) media asset.
    """
    permission_classes = [permissions.IsAuthenticated, IsCampaignMediaOwnerOrAdmin]

    def get(self, request, pk):
        media = get_object_or_404(CampaignMedia, pk=pk)
        self.check_object_permissions(request, media)
        return Response({
            "success": True,
            "media": CampaignMediaSerializer(media, context={"request": request}).data,
        }, status=status.HTTP_200_OK)

    def patch(self, request, pk):
        media = get_object_or_404(CampaignMedia, pk=pk)
        self.check_object_permissions(request, media)

        serializer = CampaignMediaUpdateSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            updated = CampaignMediaService.update_media(
                media=media,
                user=request.user,
                title=data.get("title"),
                description=data.get("description"),
                status=data.get("status"),
            )
            return Response({
                "success": True,
                "media": CampaignMediaSerializer(updated, context={"request": request}).data,
            }, status=status.HTTP_200_OK)
        except (ValidationError, PermissionDenied) as e:
            return Response({
                "success": False,
                "error": getattr(e, "message_dict", getattr(e, "message", str(e))),
            }, status=status.HTTP_400_BAD_REQUEST if isinstance(e, ValidationError) else status.HTTP_403_FORBIDDEN)

    def delete(self, request, pk):
        media = get_object_or_404(CampaignMedia, pk=pk)
        self.check_object_permissions(request, media)

        try:
            disabled = CampaignMediaService.disable_media(media=media, user=request.user)
            return Response({
                "success": True,
                "message": "Media asset disabled successfully.",
                "media": CampaignMediaSerializer(disabled, context={"request": request}).data,
            }, status=status.HTTP_200_OK)
        except PermissionDenied as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_403_FORBIDDEN)


class CampaignMediaRestoreView(views.APIView):
    """
    POST /api/v1/campaign-media/<uuid:pk>/restore/ - Restore disabled media asset.
    """
    permission_classes = [permissions.IsAuthenticated, IsCampaignMediaOwnerOrAdmin]

    def post(self, request, pk):
        media = get_object_or_404(CampaignMedia, pk=pk)
        self.check_object_permissions(request, media)

        try:
            restored = CampaignMediaService.restore_media(media=media, user=request.user)
            return Response({
                "success": True,
                "message": "Media asset restored to READY status.",
                "media": CampaignMediaSerializer(restored, context={"request": request}).data,
            }, status=status.HTTP_200_OK)
        except PermissionDenied as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_403_FORBIDDEN)

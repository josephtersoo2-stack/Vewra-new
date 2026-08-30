from decimal import Decimal
from django.http import HttpResponse
from django.shortcuts import get_object_or_404
from rest_framework import views, status, permissions
from rest_framework.response import Response
from django.core.exceptions import ValidationError, PermissionDenied

from apps.campaigns.models import Campaign
from apps.advertising.billing.models import (
    AdvertiserWallet,
    CampaignBudget,
    AdvertisementCharge,
    BudgetStatus,
)
from apps.advertising.billing.serializers import (
    AdvertiserWalletSerializer,
    WalletFundingSerializer,
    CampaignBudgetSerializer,
    CampaignBudgetConfigureSerializer,
    AdvertisementChargeSerializer,
)
from apps.advertising.billing.services import AdvertiserBillingService
from apps.campaigns.permissions import is_advertiser_capable


class IsAdvertiserOrAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        if not (request.user and request.user.is_authenticated):
            return False
        return is_advertiser_capable(request.user)


class AdvertiserWalletView(views.APIView):
    """
    GET /api/v1/advertiser/wallet/ - Retrieve current advertiser wallet balance and spending summary.
    """
    permission_classes = [permissions.IsAuthenticated, IsAdvertiserOrAdmin]

    def get(self, request):
        wallet = AdvertiserBillingService.get_or_create_wallet(request.user)
        serializer = AdvertiserWalletSerializer(wallet)
        return Response(serializer.data, status=status.HTTP_200_OK)


class AdvertiserWalletFundView(views.APIView):
    """
    POST /api/v1/advertiser/wallet/fund/ - Deposit funds into the advertiser balance.
    """
    permission_classes = [permissions.IsAuthenticated, IsAdvertiserOrAdmin]

    def post(self, request):
        serializer = WalletFundingSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        wallet = AdvertiserBillingService.fund_wallet(
            user=request.user,
            amount=data["amount"],
            currency=data.get("currency", "USD"),
        )
        return Response({
            "success": True,
            "message": f"Successfully deposited ${data['amount']:.2f} to advertiser wallet.",
            "wallet": AdvertiserWalletSerializer(wallet).data,
        }, status=status.HTTP_200_OK)


class AdvertiserBillingHistoryView(views.APIView):
    """
    GET /api/v1/advertiser/billing/history/ - List historical advertisement charges and event monetisation.
    """
    permission_classes = [permissions.IsAuthenticated, IsAdvertiserOrAdmin]

    def get(self, request):
        is_admin = request.user.is_staff or getattr(request.user, "is_superuser", False) or str(getattr(request.user, "role", "")).lower() == "admin"
        charges_qs = AdvertisementCharge.objects.all() if is_admin else AdvertisementCharge.objects.filter(advertiser=request.user)

        campaign_id = request.query_params.get("campaign_id")
        if campaign_id:
            charges_qs = charges_qs.filter(campaign_id=campaign_id)

        event_type = request.query_params.get("event_type")
        if event_type:
            charges_qs = charges_qs.filter(event_type=event_type.upper())

        limit = min(int(request.query_params.get("limit", 50)), 200)
        charges = charges_qs.select_related("campaign", "advertiser")[:limit]

        serializer = AdvertisementChargeSerializer(charges, many=True)
        return Response({
            "success": True,
            "count": len(serializer.data),
            "charges": serializer.data,
            "results": serializer.data,
        }, status=status.HTTP_200_OK)


class CampaignSpendingView(views.APIView):
    """
    GET /api/v1/campaigns/<uuid:campaign_id>/spending/ - Spending breakdown, budget usage, and unit pricing.
    """
    permission_classes = [permissions.IsAuthenticated, IsAdvertiserOrAdmin]

    def get(self, request, campaign_id):
        try:
            summary = AdvertiserBillingService.generate_spending_summary(campaign_id=campaign_id, user=request.user)
            return Response(summary, status=status.HTTP_200_OK)
        except PermissionDenied as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_403_FORBIDDEN)
        except Campaign.DoesNotExist:
            return Response({"success": False, "error": "Campaign not found."}, status=status.HTTP_404_NOT_FOUND)


class CampaignBudgetConfigureView(views.APIView):
    """
    POST /api/v1/campaigns/<uuid:campaign_id>/budget/ - Configure budget limits, daily caps, and unit pricing.
    """
    permission_classes = [permissions.IsAuthenticated, IsAdvertiserOrAdmin]

    def post(self, request, campaign_id):
        campaign = get_object_or_404(Campaign, pk=campaign_id)
        is_admin = request.user.is_staff or getattr(request.user, "is_superuser", False) or str(getattr(request.user, "role", "")).lower() == "admin"
        if campaign.owner != request.user and not is_admin:
            raise PermissionDenied("You do not have permission to configure budget for this campaign.")

        serializer = CampaignBudgetConfigureSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        budget = AdvertiserBillingService.get_or_create_budget(campaign)

        if "daily_budget" in data:
            budget.daily_budget = data["daily_budget"]
        if "total_budget" in data:
            budget.total_budget = data["total_budget"]
            campaign.budget = data["total_budget"]
            campaign.save(update_fields=["budget"])
        if "cpm_rate" in data:
            budget.cpm_rate = data["cpm_rate"]
        if "cpc_rate" in data:
            budget.cpc_rate = data["cpc_rate"]
        if "cpv_rate" in data:
            budget.cpv_rate = data["cpv_rate"]
        if "start_date" in data:
            budget.start_date = data["start_date"]
        if "end_date" in data:
            budget.end_date = data["end_date"]
        if "status" in data:
            budget.status = data["status"]

        budget.save()
        return Response({
            "success": True,
            "message": "Campaign budget configured successfully.",
            "budget": CampaignBudgetSerializer(budget).data,
        }, status=status.HTTP_200_OK)


class AdvertiserReportView(views.APIView):
    """
    GET /api/v1/advertiser/reports/ - Generate comprehensive financial attribution & ROI report.
    """
    permission_classes = [permissions.IsAuthenticated, IsAdvertiserOrAdmin]

    def get(self, request):
        campaign_id = request.query_params.get("campaign_id")
        start_date = request.query_params.get("start_date")
        end_date = request.query_params.get("end_date")

        report = AdvertiserBillingService.generate_financial_report(
            user=request.user,
            campaign_id=campaign_id,
            start_date=start_date,
            end_date=end_date,
        )
        return Response(report, status=status.HTTP_200_OK)


class AdvertiserReportExportView(views.APIView):
    """
    GET /api/v1/advertiser/reports/export/ - Download financial performance report as CSV.
    """
    permission_classes = [permissions.IsAuthenticated, IsAdvertiserOrAdmin]

    def perform_content_negotiation(self, request, force=False):
        from rest_framework.renderers import JSONRenderer
        return (JSONRenderer(), "application/json")

    def get(self, request):
        campaign_id = request.query_params.get("campaign_id")
        export_format = request.query_params.get("format", "csv").lower()

        if export_format == "csv":
            csv_content = AdvertiserBillingService.export_report_csv(
                user=request.user,
                campaign_id=campaign_id,
            )
            response = HttpResponse(csv_content, content_type="text/csv")
            response["Content-Disposition"] = 'attachment; filename="advertiser_financial_report.csv"'
            return response

        # Default JSON format
        report = AdvertiserBillingService.generate_financial_report(
            user=request.user,
            campaign_id=campaign_id,
        )
        return Response(report, status=status.HTTP_200_OK)

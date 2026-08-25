from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import SubscriptionTier, UserSubscription
from .serializers import SubscriptionTierSerializer, UserSubscriptionSerializer
from .services import SubscriptionService

class SubscriptionTierListView(APIView):
    """API endpoint to list all available subscription plans."""

    permission_classes = (permissions.AllowAny,)

    def get(self, request, *args, **kwargs):
        SubscriptionService.ensure_default_tiers()
        tiers = SubscriptionTier.objects.filter(active=True).order_by('monthly_price')
        serializer = SubscriptionTierSerializer(tiers, many=True)
        return Response(
            {
                'status': 'success',
                'plans': serializer.data,
            },
            status=status.HTTP_200_OK
        )


class UserSubscriptionDetailView(APIView):
    """API endpoint to get the authenticated user's current subscription."""

    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        subscription = SubscriptionService.get_user_subscription(request.user)
        serializer = UserSubscriptionSerializer(subscription)
        return Response(
            {
                'status': 'success',
                'subscription': serializer.data,
            },
            status=status.HTTP_200_OK
        )

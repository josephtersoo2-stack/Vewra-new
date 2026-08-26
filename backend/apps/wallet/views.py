from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from django.core.exceptions import ValidationError
from .models import (
    Wallet,
    CoinTransaction,
    CashTransaction,
    WithdrawalRequest,
)
from .serializers import (
    WalletSerializer,
    CoinTransactionSerializer,
    CashTransactionSerializer,
    WithdrawalRequestSerializer,
    WithdrawalCreateSerializer,
    CoinTransferSerializer,
)
from .services import WalletService

class WalletBalanceView(APIView):
    """API endpoint to get the authenticated user's live wallet balances and stats."""

    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        wallet = WalletService.get_or_create_wallet(request.user)
        serializer = WalletSerializer(wallet)
        return Response(
            {
                'status': 'success',
                'wallet': serializer.data,
            },
            status=status.HTTP_200_OK
        )


class WalletTransactionsView(APIView):
    """API endpoint to retrieve unified or fiat cash transaction history."""

    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        tx_type = request.query_params.get('type')
        queryset = CashTransaction.objects.filter(user=request.user)
        if tx_type:
            queryset = queryset.filter(transaction_type=tx_type.upper())
        serializer = CashTransactionSerializer(queryset[:50], many=True)
        return Response(
            {
                'status': 'success',
                'count': queryset.count(),
                'transactions': serializer.data,
            },
            status=status.HTTP_200_OK
        )


class CoinHistoryView(APIView):
    """API endpoint to retrieve detailed coin ledger and audit history."""

    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        tx_type = request.query_params.get('type')
        queryset = CoinTransaction.objects.filter(user=request.user)
        if tx_type:
            queryset = queryset.filter(transaction_type=tx_type.upper())
        serializer = CoinTransactionSerializer(queryset[:100], many=True)
        return Response(
            {
                'status': 'success',
                'count': queryset.count(),
                'coin_transactions': serializer.data,
            },
            status=status.HTTP_200_OK
        )


class CoinTransferView(APIView):
    """API endpoint to perform P2P coin transfers to another community member."""

    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, *args, **kwargs):
        serializer = CoinTransferSerializer(data=request.data)
        if serializer.is_valid():
            try:
                reference = WalletService.transfer_coins(
                    sender=request.user,
                    recipient_username=serializer.validated_data['recipient_username'],
                    amount=serializer.validated_data['amount'],
                    description=serializer.validated_data.get('description', ''),
                )
                wallet = WalletService.get_or_create_wallet(request.user)
                return Response(
                    {
                        'status': 'success',
                        'message': f"Successfully transferred {serializer.validated_data['amount']} Coins.",
                        'reference': reference,
                        'wallet': WalletSerializer(wallet).data,
                    },
                    status=status.HTTP_200_OK
                )
            except ValidationError as e:
                return Response(
                    {
                        'status': 'error',
                        'message': str(e.message if hasattr(e, 'message') else e),
                    },
                    status=status.HTTP_400_BAD_REQUEST
                )
        return Response(
            {
                'status': 'error',
                'errors': serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST
        )


class WithdrawalListView(APIView):
    """API endpoint to view user's withdrawal request history and status."""

    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        requests = WithdrawalRequest.objects.filter(user=request.user)
        serializer = WithdrawalRequestSerializer(requests, many=True)
        return Response(
            {
                'status': 'success',
                'count': requests.count(),
                'withdrawals': serializer.data,
            },
            status=status.HTTP_200_OK
        )


class WithdrawalCreateView(APIView):
    """API endpoint to initiate a payout withdrawal request."""

    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, *args, **kwargs):
        serializer = WithdrawalCreateSerializer(data=request.data)
        if serializer.is_valid():
            try:
                withdrawal = WalletService.create_withdrawal_request(
                    user=request.user,
                    amount=serializer.validated_data['amount'],
                    method=serializer.validated_data['method'],
                    destination=serializer.validated_data['destination'],
                )
                wallet = WalletService.get_or_create_wallet(request.user)
                return Response(
                    {
                        'status': 'success',
                        'message': 'Withdrawal request created successfully and queued for processing.',
                        'withdrawal': WithdrawalRequestSerializer(withdrawal).data,
                        'wallet': WalletSerializer(wallet).data,
                    },
                    status=status.HTTP_201_CREATED
                )
            except ValidationError as e:
                return Response(
                    {
                        'status': 'error',
                        'message': str(e.message if hasattr(e, 'message') else e),
                    },
                    status=status.HTTP_400_BAD_REQUEST
                )
        return Response(
            {
                'status': 'error',
                'errors': serializer.errors,
            },
            status=status.HTTP_400_BAD_REQUEST
        )

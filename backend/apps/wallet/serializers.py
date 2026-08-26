from decimal import Decimal
from rest_framework import serializers
from .models import (
    Wallet,
    CoinTransaction,
    CashTransaction,
    WithdrawalRequest,
    DepositRecord,
    WithdrawalMethod,
)

class WalletSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = Wallet
        fields = (
            'username',
            'coin_balance',
            'cash_balance',
            'pending_cash',
            'pending_coins',
            'lifetime_coins',
            'lifetime_cash',
            'currency',
            'created_at',
            'updated_at',
        )
        read_only_fields = fields


class CoinTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = CoinTransaction
        fields = (
            'id',
            'transaction_type',
            'amount',
            'balance_before',
            'balance_after',
            'reference',
            'description',
            'created_at',
        )
        read_only_fields = fields


class CashTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = CashTransaction
        fields = (
            'id',
            'transaction_type',
            'amount',
            'currency',
            'status',
            'reference',
            'description',
            'created_at',
        )
        read_only_fields = fields


class WithdrawalRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = WithdrawalRequest
        fields = (
            'id',
            'amount',
            'coins_deducted',
            'currency',
            'method',
            'status',
            'destination',
            'admin_notes',
            'created_at',
            'processed_at',
        )
        read_only_fields = (
            'id',
            'coins_deducted',
            'currency',
            'status',
            'admin_notes',
            'created_at',
            'processed_at',
        )


class WithdrawalCreateSerializer(serializers.Serializer):
    amount = serializers.DecimalField(max_digits=12, decimal_places=2, min_value=Decimal('0.01'))
    method = serializers.ChoiceField(choices=WithdrawalMethod.choices, default=WithdrawalMethod.USDT)
    destination = serializers.CharField(max_length=255, required=True)


class CoinTransferSerializer(serializers.Serializer):
    recipient_username = serializers.CharField(max_length=150, required=True)
    amount = serializers.IntegerField(min_value=1, required=True)
    description = serializers.CharField(max_length=255, required=False, allow_blank=True, default='')


class DepositRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = DepositRecord
        fields = (
            'id',
            'amount',
            'currency',
            'payment_method',
            'status',
            'reference',
            'created_at',
        )
        read_only_fields = fields

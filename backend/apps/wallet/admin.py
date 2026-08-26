from django.contrib import admin
from .models import (
    Wallet,
    CoinTransaction,
    CashTransaction,
    WithdrawalRequest,
    DepositRecord,
)

@admin.register(Wallet)
class WalletAdmin(admin.ModelAdmin):
    list_display = ('user', 'coin_balance', 'cash_balance', 'pending_coins', 'pending_cash', 'currency', 'updated_at')
    search_fields = ('user__username', 'user__email')
    readonly_fields = ('created_at', 'updated_at')


@admin.register(CoinTransaction)
class CoinTransactionAdmin(admin.ModelAdmin):
    list_display = ('user', 'transaction_type', 'amount', 'balance_before', 'balance_after', 'reference', 'created_at')
    list_filter = ('transaction_type',)
    search_fields = ('user__username', 'reference', 'description')
    readonly_fields = ('created_at',)


@admin.register(CashTransaction)
class CashTransactionAdmin(admin.ModelAdmin):
    list_display = ('user', 'transaction_type', 'amount', 'currency', 'status', 'reference', 'created_at')
    list_filter = ('transaction_type', 'status')
    search_fields = ('user__username', 'reference', 'description')
    readonly_fields = ('created_at',)


@admin.register(WithdrawalRequest)
class WithdrawalRequestAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'amount', 'currency', 'method', 'status', 'destination', 'created_at', 'processed_at')
    list_filter = ('status', 'method')
    search_fields = ('user__username', 'destination', 'admin_notes')
    readonly_fields = ('created_at',)


@admin.register(DepositRecord)
class DepositRecordAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'amount', 'currency', 'payment_method', 'status', 'reference', 'created_at')
    list_filter = ('status', 'payment_method')
    search_fields = ('user__username', 'reference')
    readonly_fields = ('created_at',)

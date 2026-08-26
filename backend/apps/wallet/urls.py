from django.urls import path
from .views import (
    WalletBalanceView,
    WalletTransactionsView,
    CoinHistoryView,
    CoinTransferView,
    WithdrawalListView,
    WithdrawalCreateView,
)

urlpatterns = [
    path('balance/', WalletBalanceView.as_view(), name='wallet-balance'),
    path('transactions/', WalletTransactionsView.as_view(), name='wallet-transactions'),
    path('coins/history/', CoinHistoryView.as_view(), name='wallet-coins-history'),
    path('coins/transfer/', CoinTransferView.as_view(), name='wallet-coins-transfer'),
    path('withdrawals/', WithdrawalListView.as_view(), name='wallet-withdrawals-list'),
    path('withdrawals/create/', WithdrawalCreateView.as_view(), name='wallet-withdrawals-create'),
]

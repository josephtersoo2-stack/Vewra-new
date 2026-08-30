from django.urls import path
from apps.advertising.billing.views import (
    AdvertiserWalletView,
    AdvertiserWalletFundView,
    AdvertiserBillingHistoryView,
    CampaignSpendingView,
    CampaignBudgetConfigureView,
    AdvertiserReportView,
    AdvertiserReportExportView,
)

urlpatterns = [
    path("wallet/", AdvertiserWalletView.as_view(), name="advertiser-wallet"),
    path("wallet/fund/", AdvertiserWalletFundView.as_view(), name="advertiser-wallet-fund"),
    path("billing/history/", AdvertiserBillingHistoryView.as_view(), name="advertiser-billing-history"),
    path("reports/export/", AdvertiserReportExportView.as_view(), name="advertiser-reports-export"),
    path("reports/", AdvertiserReportView.as_view(), name="advertiser-reports"),
]

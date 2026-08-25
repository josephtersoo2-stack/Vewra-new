from django.urls import path
from .views import (
    VerificationStatusView,
    VerificationSubmitView,
    TrustScoreHistoryView,
    DeviceRegisterView,
)

urlpatterns = [
    # Verification Endpoints
    path('verification/', VerificationStatusView.as_view(), name='security-verification-status'),
    path('verification/status/', VerificationStatusView.as_view(), name='security-verification-status-detail'),
    path('verification/submit/', VerificationSubmitView.as_view(), name='security-verification-submit'),

    # Trust Score History Endpoint
    path('trust/history/', TrustScoreHistoryView.as_view(), name='security-trust-history'),

    # Device Security Endpoint
    path('device/', DeviceRegisterView.as_view(), name='security-device-register'),
]

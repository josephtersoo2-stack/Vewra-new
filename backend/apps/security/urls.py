from django.urls import path
from .views import VerificationStatusView, DeviceRegisterView

urlpatterns = [
    path('verification/', VerificationStatusView.as_view(), name='security-verification-status'),
    path('device/', DeviceRegisterView.as_view(), name='security-device-register'),
]

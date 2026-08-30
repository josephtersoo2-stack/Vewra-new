from django.urls import path
from apps.campaigns.tracking.views import (
    RecordImpressionView,
    RecordClickView,
    RecordVideoProgressView,
)
from apps.campaigns.views import ActiveAdsDeliveryView

urlpatterns = [
    path("impression/", RecordImpressionView.as_view(), name="ad-record-impression"),
    path("click/", RecordClickView.as_view(), name="ad-record-click"),
    path("video-progress/", RecordVideoProgressView.as_view(), name="ad-record-video-progress"),
    path("<str:placement_type>/", ActiveAdsDeliveryView.as_view(), name="active-ads-delivery"),
]

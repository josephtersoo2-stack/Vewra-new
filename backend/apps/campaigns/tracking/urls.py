from django.urls import path
from apps.campaigns.tracking.views import (
    RecordImpressionView,
    RecordClickView,
    RecordVideoProgressView,
    CampaignAnalyticsView,
    AdvertiserOverviewAnalyticsView,
)

urlpatterns = [
    path("ads/impression/", RecordImpressionView.as_view(), name="ad-record-impression"),
    path("ads/click/", RecordClickView.as_view(), name="ad-record-click"),
    path("ads/video-progress/", RecordVideoProgressView.as_view(), name="ad-record-video-progress"),
    path("campaigns/<uuid:campaign_id>/analytics/", CampaignAnalyticsView.as_view(), name="campaign-analytics"),
    path("advertiser/analytics/", AdvertiserOverviewAnalyticsView.as_view(), name="advertiser-overview-analytics"),
]

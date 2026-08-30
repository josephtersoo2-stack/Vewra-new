from django.urls import path
from .views import CampaignPlacementDetailView, CampaignPlacementRestoreView

urlpatterns = [
    path("", CampaignPlacementDetailView.as_view(), name="ad-placement-detail"),
    path("restore/", CampaignPlacementRestoreView.as_view(), name="ad-placement-restore"),
]

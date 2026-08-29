from django.urls import path
from .views import CampaignMediaDetailView, CampaignMediaRestoreView

app_name = "campaign_media"

urlpatterns = [
    path("", CampaignMediaDetailView.as_view(), name="detail"),
    path("restore/", CampaignMediaRestoreView.as_view(), name="restore"),
]

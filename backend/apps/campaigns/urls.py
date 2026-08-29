from django.urls import path
from .views import (
    CampaignListCreateView,
    CampaignDetailView,
    CampaignSubmitReviewView,
    CampaignApproveView,
    CampaignRejectView,
    CampaignPauseView,
    CampaignMediaListCreateView,
    CampaignMediaDetailView,
    CampaignMediaRestoreView,
)

app_name = "campaigns"

urlpatterns = [
    path("", CampaignListCreateView.as_view(), name="campaign-list"),
    path("create/", CampaignListCreateView.as_view(), name="campaign-create"),
    path("<uuid:pk>/", CampaignDetailView.as_view(), name="campaign-detail"),
    path("<uuid:pk>/submit/", CampaignSubmitReviewView.as_view(), name="campaign-submit-review"),
    path("<uuid:pk>/approve/", CampaignApproveView.as_view(), name="campaign-approve"),
    path("<uuid:pk>/reject/", CampaignRejectView.as_view(), name="campaign-reject"),
    path("<uuid:pk>/pause/", CampaignPauseView.as_view(), name="campaign-pause"),
    # Media endpoints
    path("<uuid:campaign_id>/media/", CampaignMediaListCreateView.as_view(), name="campaign-media-list"),
    path("<uuid:campaign_id>/media/upload/", CampaignMediaListCreateView.as_view(), name="campaign-media-upload"),
    path("media/<uuid:pk>/", CampaignMediaDetailView.as_view(), name="campaign-media-detail"),
    path("media/<uuid:pk>/restore/", CampaignMediaRestoreView.as_view(), name="campaign-media-restore"),
]

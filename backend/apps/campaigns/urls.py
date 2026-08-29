from django.urls import path
from .views import (
    CampaignListCreateView,
    CampaignDetailView,
    CampaignSubmitReviewView,
    CampaignApproveView,
    CampaignRejectView,
    CampaignPauseView,
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
]

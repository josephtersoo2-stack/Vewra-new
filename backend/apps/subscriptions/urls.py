from django.urls import path
from .views import SubscriptionTierListView, UserSubscriptionDetailView

urlpatterns = [
    path('plans/', SubscriptionTierListView.as_view(), name='subscription-plans-list'),
    path('my-subscription/', UserSubscriptionDetailView.as_view(), name='user-subscription-detail'),
]

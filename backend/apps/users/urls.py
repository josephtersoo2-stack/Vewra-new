from django.urls import path
from .views import (
    UserProfileView,
    UserProfileUpdateView,
    PublicUserProfileView,
    UserStatisticsView,
    UserPreferenceView,
)

urlpatterns = [
    # Profile Endpoints
    path('profile/', UserProfileView.as_view(), name='user-profile'),
    path('profile/update/', UserProfileUpdateView.as_view(), name='user-profile-update'),
    path('update-profile/', UserProfileUpdateView.as_view(), name='user-update-profile-alias'),
    path('profile/statistics/', UserStatisticsView.as_view(), name='user-statistics'),
    path('profile/<str:username>/', PublicUserProfileView.as_view(), name='user-public-profile'),

    # Preferences Endpoints
    path('preferences/', UserPreferenceView.as_view(), name='user-preferences'),
    path('preferences/update/', UserPreferenceView.as_view(), name='user-preferences-update'),
]

from django.urls import path
from .views import UserProfileView, UserUpdateView

urlpatterns = [
    path('profile/', UserProfileView.as_view(), name='user-profile'),
    path('update-profile/', UserUpdateView.as_view(), name='user-update-profile'),
]

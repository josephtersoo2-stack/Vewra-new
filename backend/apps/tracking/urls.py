from django.urls import path
from .views import (
    WatchSessionDetailView,
    WatchHeartbeatView,
    WatchEventView,
    WatchCompletionView,
    WatchAbandonView,
)

urlpatterns = [
    path('sessions/<str:id>/', WatchSessionDetailView.as_view(), name='tracking-session-detail'),
    path('sessions/<str:id>/heartbeat/', WatchHeartbeatView.as_view(), name='tracking-heartbeat'),
    path('sessions/<str:id>/events/', WatchEventView.as_view(), name='tracking-events'),
    path('sessions/<str:id>/complete/', WatchCompletionView.as_view(), name='tracking-complete'),
    path('sessions/<str:id>/abandon/', WatchAbandonView.as_view(), name='tracking-abandon'),
]

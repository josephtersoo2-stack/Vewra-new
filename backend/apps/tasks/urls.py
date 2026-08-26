from django.urls import path
from .views import (
    TaskListView,
    TaskDetailView,
    TaskEligibilityView,
    TaskStartView,
    TaskAttemptListView,
    TaskAttemptDetailView,
    TaskQuizView,
    TaskQuizSubmitView,
)

urlpatterns = [
    path('', TaskListView.as_view(), name='task-list'),
    path('<str:id>/', TaskDetailView.as_view(), name='task-detail'),
    path('<str:id>/eligibility/', TaskEligibilityView.as_view(), name='task-eligibility'),
    path('<str:id>/start/', TaskStartView.as_view(), name='task-start'),
    
    path('attempts/', TaskAttemptListView.as_view(), name='task-attempts-list'),
    path('attempts/<uuid:attempt_id>/', TaskAttemptDetailView.as_view(), name='task-attempt-detail'),
    path('attempts/<uuid:attempt_id>/quiz/', TaskQuizView.as_view(), name='task-quiz'),
    path('attempts/<uuid:attempt_id>/quiz/submit/', TaskQuizSubmitView.as_view(), name='task-quiz-submit'),
]

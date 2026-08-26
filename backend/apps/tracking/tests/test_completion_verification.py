from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from apps.authentication.services import AuthService
from apps.tasks.models import Task, TaskType, TaskAttempt, TaskAttemptStatus, TaskRewardGrant
from apps.tracking.models import WatchSession, WatchSessionStatus
from apps.tracking.services import WatchSessionService

User = get_user_model()

class CompletionVerificationTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='verifier_user',
            email='verify@vewra.io',
            password='Password123!',
        )
        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

        self.task = Task.objects.create(
            title='Direct Completion Video Task',
            task_type=TaskType.VIDEO,
            source_url='https://example.com/video',
            reward_coins=50,
            required_watch_seconds=30,
            quiz_required=False,
        )
        self.attempt = TaskAttempt.objects.create(
            user=self.user,
            task=self.task,
        )
        self.session, self.raw_token = WatchSessionService.create_session(
            attempt=self.attempt,
            user=self.user,
            task=self.task,
        )
        self.complete_url = reverse('tracking-complete', kwargs={'id': self.session.id})

    def test_incomplete_watch_time_rejected(self):
        self.session.credited_watch_seconds = 10
        self.session.save()

        response = self.client.post(
            self.complete_url,
            HTTP_X_VEWRA_WATCH_TOKEN=self.raw_token,
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'INCOMPLETE')
        self.assertEqual(response.data['code'], 'INSUFFICIENT_WATCH_TIME')

    def test_satisfied_watch_time_completes_and_rewards(self):
        self.session.credited_watch_seconds = 30
        self.session.save()

        response = self.client.post(
            self.complete_url,
            HTTP_X_VEWRA_WATCH_TOKEN=self.raw_token,
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'COMPLETED')
        self.assertEqual(response.data['reward']['coins'], 50)

        # Check attempt updated
        self.attempt.refresh_from_db()
        self.assertEqual(self.attempt.status, TaskAttemptStatus.COMPLETED)
        self.assertTrue(self.attempt.reward_granted)

        # Check wallet credited
        self.user.wallet.refresh_from_db()
        self.assertEqual(self.user.wallet.coin_balance, 50)

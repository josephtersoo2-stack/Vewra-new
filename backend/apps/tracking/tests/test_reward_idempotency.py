from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from apps.authentication.services import AuthService
from apps.tasks.models import Task, TaskType, TaskAttempt, TaskRewardGrant
from apps.tracking.services import WatchSessionService

User = get_user_model()

class RewardIdempotencyTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='idempotent_user',
            email='idempotent@vewra.io',
            password='Password123!',
        )
        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

        self.task = Task.objects.create(
            title='Idempotency Test Task',
            task_type=TaskType.VIDEO,
            source_url='https://example.com/video',
            reward_coins=40,
            required_watch_seconds=20,
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

    def test_repeated_completion_calls_credit_wallet_only_once(self):
        self.session.credited_watch_seconds = 20
        self.session.save()

        # Call 1
        resp1 = self.client.post(self.complete_url, HTTP_X_VEWRA_WATCH_TOKEN=self.raw_token)
        self.assertEqual(resp1.status_code, status.HTTP_200_OK)
        self.assertEqual(resp1.data['status'], 'COMPLETED')

        self.user.wallet.refresh_from_db()
        self.assertEqual(self.user.wallet.coin_balance, 40)
        self.assertEqual(TaskRewardGrant.objects.filter(user=self.user, task=self.task).count(), 1)

        # Call 2 (Duplicate complete request)
        resp2 = self.client.post(self.complete_url, HTTP_X_VEWRA_WATCH_TOKEN=self.raw_token)
        self.assertEqual(resp2.status_code, status.HTTP_200_OK)
        self.assertEqual(resp2.data['status'], 'ALREADY_COMPLETED')

        # Balance remains exactly 40, no double credit
        self.user.wallet.refresh_from_db()
        self.assertEqual(self.user.wallet.coin_balance, 40)
        self.assertEqual(TaskRewardGrant.objects.filter(user=self.user, task=self.task).count(), 1)

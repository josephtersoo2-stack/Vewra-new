from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from apps.authentication.services import AuthService
from apps.tasks.models import Task, TaskType, TaskAttempt
from apps.tracking.models import WatchSession, WatchSessionStatus
from apps.tracking.services import WatchSessionService

User = get_user_model()

class HeartbeatApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='hb_user',
            email='hb@vewra.io',
            password='Password123!',
        )
        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

        self.task = Task.objects.create(
            title='Heartbeat Verification Task',
            task_type=TaskType.VIDEO,
            source_url='https://example.com/video',
            reward_coins=25,
            required_watch_seconds=30,
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
        self.heartbeat_url = reverse('tracking-heartbeat', kwargs={'id': self.session.id})

    def test_heartbeat_requires_token_header(self):
        response = self.client.post(self.heartbeat_url, {'sequence': 2})
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data['code'], 'SESSION_TOKEN_REQUIRED')

    def test_valid_heartbeat_credits_time(self):
        response = self.client.post(
            self.heartbeat_url,
            {'sequence': 2, 'playback_position': 15.0},
            HTTP_X_VEWRA_WATCH_TOKEN=self.raw_token,
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'success')
        self.session.refresh_from_db()
        self.assertEqual(self.session.last_sequence, 2)
        self.assertEqual(self.session.heartbeat_count, 1)

    def test_out_of_order_sequence_rejected(self):
        # Expected sequence is 2, sending 5
        response = self.client.post(
            self.heartbeat_url,
            {'sequence': 5},
            HTTP_X_VEWRA_WATCH_TOKEN=self.raw_token,
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['code'], 'INVALID_SEQUENCE')

from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from apps.authentication.services import AuthService
from apps.tasks.models import Task, TaskType, TaskStatus, TaskAttempt, TaskAttemptStatus

User = get_user_model()

class TaskAttemptApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='attempt_user',
            email='attempt@vewra.io',
            password='Password123!',
        )
        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

        self.task = Task.objects.create(
            title='Startable Video Task',
            task_type=TaskType.VIDEO,
            status=TaskStatus.ACTIVE,
            source_url='https://youtube.com/watch?v=123',
            reward_coins=30,
            required_watch_seconds=45,
            minimum_level=1,
            minimum_trust_score=50,
        )
        self.start_url = reverse('task-start', kwargs={'id': self.task.id})

    def test_start_task_creates_attempt_and_watch_session(self):
        response = self.client.post(self.start_url, {
            'client_platform': 'MOBILE',
            'app_version': '1.0.0',
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['status'], 'success')
        self.assertEqual(response.data['attempt']['status'], TaskAttemptStatus.IN_PROGRESS)
        self.assertIn('watch_session', response.data)
        self.assertTrue(response.data['watch_session']['watch_token'])
        self.assertEqual(response.data['watch_session']['required_seconds'], 45)

    def test_start_task_resumes_existing_active_attempt(self):
        # First start
        resp1 = self.client.post(self.start_url)
        attempt_id1 = resp1.data['attempt']['id']

        # Second start on same task
        resp2 = self.client.post(self.start_url)
        self.assertEqual(resp2.status_code, status.HTTP_200_OK)
        self.assertEqual(resp2.data['attempt']['id'], attempt_id1)
        self.assertEqual(TaskAttempt.objects.filter(user=self.user, task=self.task).count(), 1)

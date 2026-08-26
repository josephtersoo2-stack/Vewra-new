from decimal import Decimal
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from apps.authentication.services import AuthService
from apps.tasks.models import Task, TaskType, TaskStatus

User = get_user_model()

class TaskFeedApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='feed_user',
            email='feed@vewra.io',
            password='Password123!',
        )
        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

        self.task1 = Task.objects.create(
            title='YouTube Intro Tutorial',
            task_type=TaskType.VIDEO,
            status=TaskStatus.ACTIVE,
            source_url='https://youtube.com/v1',
            channel_name='CodeLab',
            search_keywords='python tutorial',
            reward_coins=20,
            required_watch_seconds=30,
        )
        self.task2 = Task.objects.create(
            title='Social Community Challenge',
            task_type=TaskType.SOCIAL,
            status=TaskStatus.ACTIVE,
            source_url='https://x.com/post',
            channel_name='CommunityHQ',
            search_keywords='social join',
            reward_coins=15,
            required_watch_seconds=0,
        )
        self.draft_task = Task.objects.create(
            title='Unpublished Draft Task',
            task_type=TaskType.VIDEO,
            status=TaskStatus.DRAFT,
            source_url='https://example.com/draft',
            reward_coins=100,
            required_watch_seconds=60,
        )

        self.list_url = reverse('task-list')

    def test_unauthenticated_request_rejected(self):
        self.client.credentials()  # clear credentials
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_fetch_active_tasks_feed(self):
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'success')
        self.assertEqual(response.data['count'], 2)  # draft excluded

    def test_filter_tasks_by_type(self):
        response = self.client.get(f"{self.list_url}?type=VIDEO")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)
        self.assertEqual(response.data['tasks'][0]['title'], 'YouTube Intro Tutorial')

    def test_search_tasks_by_keyword(self):
        response = self.client.get(f"{self.list_url}?search=python")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)
        self.assertEqual(response.data['tasks'][0]['channel_name'], 'CodeLab')

    def test_fetch_task_detail(self):
        detail_url = reverse('task-detail', kwargs={'id': self.task1.id})
        response = self.client.get(detail_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['task']['title'], 'YouTube Intro Tutorial')
        self.assertIn('eligibility', response.data)
        self.assertTrue(response.data['eligibility']['eligible'])

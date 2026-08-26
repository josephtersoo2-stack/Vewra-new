from django.test import TestCase
from django.contrib.auth import get_user_model
from apps.tasks.models import Task, TaskType, TaskAttempt
from apps.tracking.models import WatchSession, WatchSessionStatus
from apps.tracking.services import WatchSessionService

User = get_user_model()

class WatchSessionServiceTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='watch_session_user',
            email='ws@vewra.io',
            password='Password123!',
        )
        self.task = Task.objects.create(
            title='Watch Session Task',
            task_type=TaskType.VIDEO,
            source_url='https://example.com/video',
            reward_coins=20,
            required_watch_seconds=60,
        )
        self.attempt = TaskAttempt.objects.create(
            user=self.user,
            task=self.task,
        )

    def test_create_session_stores_token_hash_not_plaintext(self):
        session, raw_token = WatchSessionService.create_session(
            attempt=self.attempt,
            user=self.user,
            task=self.task,
        )
        self.assertEqual(session.status, WatchSessionStatus.ACTIVE)
        self.assertNotEqual(session.session_token_hash, raw_token)
        self.assertEqual(len(session.session_token_hash), 64)  # SHA-256 length
        self.assertTrue(WatchSessionService.validate_token(session, raw_token))
        self.assertFalse(WatchSessionService.validate_token(session, 'tampered-token'))

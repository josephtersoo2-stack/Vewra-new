from decimal import Decimal
from django.test import TestCase
from django.utils import timezone
from django.contrib.auth import get_user_model
from apps.tasks.models import Task, TaskType, TaskStatus, TaskAttempt, TaskAttemptStatus
from apps.tasks.services import TaskEligibilityService

User = get_user_model()

class TaskEligibilityTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='eligible_tester',
            email='eligible@vewra.io',
            password='Password123!',
        )
        self.task = Task.objects.create(
            title='Level 5 Exclusive Task',
            task_type=TaskType.VIDEO,
            status=TaskStatus.ACTIVE,
            source_url='https://example.com/video',
            reward_coins=50,
            required_watch_seconds=60,
            minimum_level=5,
            minimum_trust_score=70,
            daily_user_limit=1,
        )

    def test_level_threshold_blocks_ineligible_user(self):
        # User profile level default is 1
        result = TaskEligibilityService.check(self.user, self.task)
        self.assertFalse(result['eligible'])
        self.assertFalse(result['requirements']['level'])
        self.assertTrue(any('Requires minimum level 5' in r for r in result['reasons']))

    def test_eligible_when_requirements_met(self):
        if hasattr(self.user, 'profile'):
            self.user.profile.level = 5
            self.user.profile.trust_score = 85
            self.user.profile.save()

        result = TaskEligibilityService.check(self.user, self.task)
        self.assertTrue(result['eligible'])
        self.assertEqual(len(result['reasons']), 0)

    def test_daily_limit_blocks_repeated_completions(self):
        if hasattr(self.user, 'profile'):
            self.user.profile.level = 5
            self.user.profile.save()

        # Record a completed attempt today
        TaskAttempt.objects.create(
            user=self.user,
            task=self.task,
            status=TaskAttemptStatus.COMPLETED,
            completed_at=timezone.now(),
        )

        result = TaskEligibilityService.check(self.user, self.task)
        self.assertFalse(result['eligible'])
        self.assertFalse(result['requirements']['daily_limit'])

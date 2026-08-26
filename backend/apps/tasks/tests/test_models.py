from decimal import Decimal
from django.test import TestCase
from django.core.exceptions import ValidationError
from django.contrib.auth import get_user_model
from apps.tasks.models import (
    Task,
    TaskType,
    TaskStatus,
    TaskAttempt,
    TaskAttemptStatus,
    QuizQuestion,
    QuizQuestionType,
)

User = get_user_model()

class TaskModelTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='task_test_user',
            email='task_test@vewra.io',
            password='Password123!',
        )

    def test_create_valid_task(self):
        task = Task.objects.create(
            title='Test Coding Video Task',
            task_type=TaskType.VIDEO,
            source_url='https://example.com/video',
            reward_coins=50,
            reward_cash=Decimal('0.50'),
            reward_xp=100,
            required_watch_seconds=120,
            quiz_required=True,
            quiz_pass_percentage=80,
        )
        self.assertTrue(task.slug)
        self.assertTrue(task.is_active)
        self.assertEqual(task.reward_coins, 50)

    def test_invalid_video_watch_seconds_raises(self):
        with self.assertRaises(ValidationError):
            task = Task(
                title='Invalid Video Task',
                task_type=TaskType.VIDEO,
                source_url='https://example.com/video',
                required_watch_seconds=0,
            )
            task.clean()

    def test_negative_rewards_raises(self):
        with self.assertRaises(ValidationError):
            task = Task(
                title='Negative Reward Task',
                task_type=TaskType.VIDEO,
                source_url='https://example.com/video',
                reward_coins=-10,
            )
            task.clean()

    def test_quiz_question_creation(self):
        task = Task.objects.create(
            title='Task with Quiz',
            task_type=TaskType.VIDEO,
            source_url='https://example.com/video',
            required_watch_seconds=60,
        )
        q = QuizQuestion.objects.create(
            task=task,
            question_text='What was the key topic?',
            question_type=QuizQuestionType.MULTIPLE_CHOICE,
            options=['Security', 'Marketing', 'Gaming', 'Cooking'],
            correct_answer='Security',
        )
        self.assertEqual(q.correct_answer, 'Security')
        self.assertEqual(task.quiz_questions.count(), 1)

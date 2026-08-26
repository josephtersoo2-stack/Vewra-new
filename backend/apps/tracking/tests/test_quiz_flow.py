from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from apps.authentication.services import AuthService
from apps.tasks.models import Task, TaskType, TaskAttempt, QuizQuestion, QuizQuestionType
from apps.tracking.services import WatchSessionService

User = get_user_model()

class QuizFlowTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='quiz_tester',
            email='quiz@vewra.io',
            password='Password123!',
        )
        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

        self.task = Task.objects.create(
            title='Quiz Enforced Video Task',
            task_type=TaskType.VIDEO,
            source_url='https://example.com/video',
            reward_coins=75,
            required_watch_seconds=30,
            quiz_required=True,
            quiz_pass_percentage=100,
        )
        self.question = QuizQuestion.objects.create(
            task=self.task,
            question_text='What is 2 + 2?',
            question_type=QuizQuestionType.MULTIPLE_CHOICE,
            options=['3', '4', '5', '6'],
            correct_answer='4',
            active=True,
        )
        self.attempt = TaskAttempt.objects.create(
            user=self.user,
            task=self.task,
            quiz_required=True,
        )
        self.session, self.raw_token = WatchSessionService.create_session(
            attempt=self.attempt,
            user=self.user,
            task=self.task,
        )
        self.quiz_url = reverse('task-quiz', kwargs={'attempt_id': self.attempt.id})
        self.quiz_submit_url = reverse('task-quiz-submit', kwargs={'attempt_id': self.attempt.id})
        self.complete_url = reverse('tracking-complete', kwargs={'id': self.session.id})

    def test_quiz_blocked_before_watch_completed(self):
        self.session.credited_watch_seconds = 10
        self.session.save()

        response = self.client.get(self.quiz_url)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(response.data['code'], 'INSUFFICIENT_WATCH_TIME')

    def test_quiz_public_serializer_does_not_leak_correct_answer(self):
        self.session.credited_watch_seconds = 30
        self.session.save()

        response = self.client.get(self.quiz_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        question_data = response.data['questions'][0]
        self.assertNotIn('correct_answer', question_data)
        self.assertIn('options', question_data)

    def test_quiz_submit_fail_and_pass_flow(self):
        self.session.credited_watch_seconds = 30
        self.session.save()

        # 1. Attempt completion before quiz returns AWAITING_QUIZ
        comp_resp = self.client.post(self.complete_url, HTTP_X_VEWRA_WATCH_TOKEN=self.raw_token)
        self.assertEqual(comp_resp.data['status'], 'AWAITING_QUIZ')

        # 2. Submit wrong answer
        fail_resp = self.client.post(
            self.quiz_submit_url,
            {'answers': [{'question_id': str(self.question.id), 'selected_answer': '3'}]},
            format='json',
        )
        self.assertEqual(fail_resp.status_code, status.HTTP_200_OK)
        self.assertFalse(fail_resp.data['passed'])

        # 3. Submit correct answer
        pass_resp = self.client.post(
            self.quiz_submit_url,
            {'answers': [{'question_id': str(self.question.id), 'selected_answer': '4'}]},
            format='json',
        )
        self.assertEqual(pass_resp.status_code, status.HTTP_200_OK)
        self.assertTrue(pass_resp.data['passed'])

        # 4. Now completion succeeds and credits reward
        comp_resp2 = self.client.post(self.complete_url, HTTP_X_VEWRA_WATCH_TOKEN=self.raw_token)
        self.assertEqual(comp_resp2.data['status'], 'COMPLETED')
        self.assertEqual(comp_resp2.data['reward']['coins'], 75)

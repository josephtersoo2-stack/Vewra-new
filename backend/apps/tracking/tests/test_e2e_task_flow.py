from decimal import Decimal
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from apps.authentication.services import AuthService
from apps.tasks.models import Task, TaskType, TaskStatus, TaskAttemptStatus, TaskRewardGrant, QuizQuestion, QuizQuestionType
from apps.tracking.models import WatchSession
from apps.wallet.models import CoinTransaction, CoinTransactionType

User = get_user_model()

class EndToEndTaskTrackingFlowTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='e2e_earner',
            email='e2e@vewra.io',
            password='Password123!',
        )
        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

        # Seed task with 15s watch and quiz
        self.task = Task.objects.create(
            title='E2E Full Verification Video',
            task_type=TaskType.VIDEO,
            status=TaskStatus.ACTIVE,
            source_url='https://youtube.com/watch?v=fullflow',
            reward_coins=60,
            reward_cash=Decimal('0.00'),
            reward_xp=120,
            required_watch_seconds=15,
            quiz_required=True,
            quiz_pass_percentage=100,
        )
        self.question = QuizQuestion.objects.create(
            task=self.task,
            question_text='What was the core conclusion of this video?',
            question_type=QuizQuestionType.MULTIPLE_CHOICE,
            options=['Fast Rendering', 'Slow Loading', 'No Benefit', 'Skip'],
            correct_answer='Fast Rendering',
            active=True,
        )

    def test_complete_e2e_flow_from_start_to_wallet_settlement(self):
        initial_coins = self.user.wallet.coin_balance
        initial_cash = Decimal(str(self.user.wallet.cash_balance))

        # 1. Fetch Task List
        list_resp = self.client.get(reverse('task-list'))
        self.assertEqual(list_resp.status_code, status.HTTP_200_OK)
        self.assertTrue(any(t['id'] == str(self.task.id) for t in list_resp.data['tasks']))

        # 2. Check Eligibility
        elig_resp = self.client.get(reverse('task-eligibility', kwargs={'id': self.task.id}))
        self.assertEqual(elig_resp.status_code, status.HTTP_200_OK)
        self.assertTrue(elig_resp.data['eligibility']['eligible'])

        # 3. Start Task Attempt & Provision Watch Session
        start_resp = self.client.post(reverse('task-start', kwargs={'id': self.task.id}), {
            'client_platform': 'MOBILE',
            'app_version': '1.0.0',
        })
        self.assertEqual(start_resp.status_code, status.HTTP_201_CREATED)
        attempt_id = start_resp.data['attempt']['id']
        session_id = start_resp.data['watch_session']['id']
        watch_token = start_resp.data['watch_session']['watch_token']

        # 4. Satisfy Watch Duration
        hb_url = reverse('tracking-heartbeat', kwargs={'id': session_id})
        session = WatchSession.objects.get(id=session_id)
        session.credited_watch_seconds = 15
        session.save()

        # Send a valid heartbeat
        hb = self.client.post(
            hb_url,
            {'sequence': 2, 'playback_position': 15.0},
            HTTP_X_VEWRA_WATCH_TOKEN=watch_token,
        )
        self.assertEqual(hb.status_code, status.HTTP_200_OK)

        # 5. Fetch Quiz
        quiz_url = reverse('task-quiz', kwargs={'attempt_id': attempt_id})
        quiz_resp = self.client.get(quiz_url)
        self.assertEqual(quiz_resp.status_code, status.HTTP_200_OK)
        self.assertEqual(len(quiz_resp.data['questions']), 1)

        # 6. Submit Quiz Answers
        submit_url = reverse('task-quiz-submit', kwargs={'attempt_id': attempt_id})
        sub_resp = self.client.post(
            submit_url,
            {'answers': [{'question_id': str(self.question.id), 'selected_answer': 'Fast Rendering'}]},
            format='json',
        )
        self.assertEqual(sub_resp.status_code, status.HTTP_200_OK)
        self.assertTrue(sub_resp.data['passed'])

        # 7. Request Verification & Reward Settlement
        comp_url = reverse('tracking-complete', kwargs={'id': session_id})
        comp_resp = self.client.post(
            comp_url,
            HTTP_X_VEWRA_WATCH_TOKEN=watch_token,
        )
        self.assertEqual(comp_resp.status_code, status.HTTP_200_OK)
        self.assertEqual(comp_resp.data['status'], 'COMPLETED')
        self.assertEqual(comp_resp.data['reward']['coins'], 60)

        # 8. Verify Database & Wallet Records
        self.user.wallet.refresh_from_db()
        self.assertEqual(self.user.wallet.coin_balance, initial_coins + 60)
        self.assertEqual(self.user.wallet.cash_balance, initial_cash + Decimal('0.60'))

        # Verify TaskRewardGrant exists
        grant = TaskRewardGrant.objects.get(attempt_id=attempt_id)
        self.assertEqual(grant.coins, 60)
        self.assertEqual(grant.wallet_reference, f"TASK-{attempt_id}")

        # Verify CoinTransaction in ledger
        coin_tx = CoinTransaction.objects.get(reference=f"TASK-{attempt_id}")
        self.assertEqual(coin_tx.amount, 60)
        self.assertEqual(coin_tx.transaction_type, CoinTransactionType.REWARD)

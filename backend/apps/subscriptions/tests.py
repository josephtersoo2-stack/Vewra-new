from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from apps.users.models import User
from apps.authentication.services import AuthService

class SubscriptionTests(APITestCase):
    def setUp(self):
        self.plans_url = reverse('subscription-plans-list')
        self.my_sub_url = reverse('user-subscription-detail')

        self.user = User.objects.create_user(
            email='sub.user@vewra.io',
            username='sub_user',
            password='Password123!',
        )
        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

    def test_list_subscription_plans(self):
        # Plans list endpoint is open
        self.client.credentials()
        response = self.client.get(self.plans_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'success')
        self.assertTrue(len(response.data['plans']) >= 3)
        plan_names = [p['name'] for p in response.data['plans']]
        self.assertIn('FREE', plan_names)
        self.assertIn('PREMIUM', plan_names)
        self.assertIn('PRO', plan_names)

    def test_get_user_subscription(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")
        response = self.client.get(self.my_sub_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'success')
        self.assertEqual(response.data['subscription']['tier']['name'], 'FREE')
        self.assertTrue(response.data['subscription']['is_active'])

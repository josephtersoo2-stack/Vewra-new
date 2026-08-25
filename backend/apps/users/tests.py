from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from apps.users.models import User, UserProfile
from apps.authentication.services import AuthService

class UserTests(APITestCase):
    def setUp(self):
        self.profile_url = reverse('user-profile')
        self.update_url = reverse('user-update-profile')

        self.user = User.objects.create_user(
            email='alex.dev@vewra.io',
            username='alex_developer',
            password='Password123!',
            country='Canada',
            phone_number='+15551234567'
        )
        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

    def test_user_profile_auto_created(self):
        self.assertTrue(hasattr(self.user, 'profile'))
        self.assertEqual(self.user.profile.level, 1)
        self.assertEqual(self.user.profile.trust_score, 75)

    def test_get_user_profile_authenticated(self):
        response = self.client.get(self.profile_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['user']['email'], 'alex.dev@vewra.io')
        self.assertEqual(response.data['user']['username'], 'alex_developer')
        self.assertIn('profile', response.data['user'])
        self.assertEqual(response.data['user']['profile']['level'], 1)

    def test_update_user_profile(self):
        update_data = {
            'username': 'alex_prime',
            'country': 'United States',
        }
        response = self.client.patch(self.update_url, update_data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertEqual(self.user.username, 'alex_prime')
        self.assertEqual(self.user.country, 'United States')

    def test_unauthenticated_profile_access_denied(self):
        self.client.credentials()  # clear credentials
        response = self.client.get(self.profile_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

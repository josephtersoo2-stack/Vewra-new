from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from apps.users.models import User, UserProfile, UserPreference, UserStatistics
from apps.users.services import UserService
from apps.authentication.services import AuthService

class UserTests(APITestCase):
    def setUp(self):
        self.profile_url = reverse('user-profile')
        self.update_url = reverse('user-profile-update')
        self.stats_url = reverse('user-statistics')
        self.pref_url = reverse('user-preferences')
        self.pref_update_url = reverse('user-preferences-update')

        self.user = User.objects.create_user(
            email='alex.dev@vewra.io',
            username='alex_developer',
            password='Password123!',
            country='Canada',
            phone_number='+15551234567'
        )
        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

    def test_user_ecosystem_entities_auto_created(self):
        self.assertTrue(hasattr(self.user, 'profile'))
        self.assertTrue(hasattr(self.user, 'preferences'))
        self.assertTrue(hasattr(self.user, 'statistics'))
        self.assertEqual(self.user.profile.level, 1)
        self.assertEqual(self.user.profile.trust_score, 75)
        self.assertEqual(self.user.preferences.theme, 'dark')
        self.assertEqual(self.user.statistics.tasks_completed, 0)

    def test_get_user_profile_authenticated(self):
        response = self.client.get(self.profile_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['user']['email'], 'alex.dev@vewra.io')
        self.assertEqual(response.data['user']['username'], 'alex_developer')
        self.assertIn('profile', response.data['user'])
        self.assertIn('preferences', response.data['user'])
        self.assertIn('statistics', response.data['user'])

    def test_update_user_profile(self):
        update_data = {
            'display_name': 'Alex Master',
            'bio': 'Content Explorer & Creator',
            'country': 'United States',
            'city': 'San Francisco',
            'language': 'en',
            'currency': 'USD',
        }
        response = self.client.patch(self.update_url, update_data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertEqual(self.user.profile.display_name, 'Alex Master')
        self.assertEqual(self.user.profile.bio, 'Content Explorer & Creator')
        self.assertEqual(self.user.country, 'United States')

    def test_get_public_user_profile(self):
        public_url = reverse('user-public-profile', kwargs={'username': 'alex_developer'})
        # Public profiles can be accessed without authentication
        self.client.credentials()
        response = self.client.get(public_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['user']['username'], 'alex_developer')
        self.assertNotIn('email', response.data['user'])  # Private info not exposed

    def test_get_user_statistics(self):
        response = self.client.get(self.stats_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('statistics', response.data)
        self.assertEqual(response.data['statistics']['tasks_completed'], 0)

    def test_get_and_update_preferences(self):
        response = self.client.get(self.pref_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['preferences']['theme'], 'dark')

        update_resp = self.client.patch(self.pref_update_url, {'theme': 'light', 'push_notifications': False})
        self.assertEqual(update_resp.status_code, status.HTTP_200_OK)
        self.assertEqual(update_resp.data['preferences']['theme'], 'light')
        self.assertFalse(update_resp.data['preferences']['push_notifications'])

    def test_user_permission_services(self):
        # Baseline user
        self.assertFalse(UserService.can_sell_coins(self.user))
        self.assertFalse(UserService.can_withdraw(self.user))
        self.assertFalse(UserService.can_access_creator_tools(self.user))
        self.assertTrue(UserService.can_access_marketplace_features(self.user))

        # Qualified user
        self.user.profile.level = 15
        self.user.profile.trust_score = 95
        self.user.profile.verification_status = 'Verified'
        self.user.profile.subscription_tier = 'Premium'
        self.user.is_verified = True
        self.user.profile.save()

        self.assertTrue(UserService.can_sell_coins(self.user))
        self.assertTrue(UserService.can_withdraw(self.user))
        self.assertTrue(UserService.can_access_creator_tools(self.user))

from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from apps.users.models import User
from apps.authentication.services import AuthService

class AuthenticationTests(APITestCase):
    def setUp(self):
        self.register_url = reverse('auth-register')
        self.login_url = reverse('auth-login')
        self.logout_url = reverse('auth-logout')
        self.refresh_url = reverse('auth-refresh')
        self.reset_request_url = reverse('auth-password-reset-request')
        self.reset_confirm_url = reverse('auth-password-reset-confirm')

        self.user_data = {
            'email': 'testuser@vewra.io',
            'username': 'testuser',
            'password': 'StrongPassword123!',
            'country': 'United States',
        }

    def test_user_registration_success(self):
        response = self.client.post(self.register_url, self.user_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['status'], 'success')
        self.assertIn('tokens', response.data)
        self.assertIn('access', response.data['tokens'])
        self.assertIn('refresh', response.data['tokens'])
        self.assertEqual(response.data['user']['email'], 'testuser@vewra.io')
        self.assertEqual(response.data['user']['username'], 'testuser')
        self.assertTrue(User.objects.filter(email='testuser@vewra.io').exists())

    def test_user_registration_duplicate_email(self):
        self.client.post(self.register_url, self.user_data)
        dup_data = self.user_data.copy()
        dup_data['username'] = 'differentuser'
        response = self.client.post(self.register_url, dup_data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('errors', response.data)

    def test_user_registration_duplicate_username(self):
        self.client.post(self.register_url, self.user_data)
        dup_data = self.user_data.copy()
        dup_data['email'] = 'different@vewra.io'
        response = self.client.post(self.register_url, dup_data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_user_login_success(self):
        User.objects.create_user(**self.user_data)
        login_payload = {
            'email': self.user_data['email'],
            'password': self.user_data['password'],
        }
        response = self.client.post(self.login_url, login_payload)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('tokens', response.data)
        self.assertIn('access', response.data['tokens'])

    def test_user_login_invalid_password(self):
        User.objects.create_user(**self.user_data)
        login_payload = {
            'email': self.user_data['email'],
            'password': 'WrongPassword!',
        }
        response = self.client.post(self.login_url, login_payload)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_token_refresh_success(self):
        user = User.objects.create_user(**self.user_data)
        login_resp = self.client.post(self.login_url, {
            'email': user.email,
            'password': self.user_data['password']
        })
        refresh_token = login_resp.data['tokens']['refresh']

        refresh_resp = self.client.post(self.refresh_url, {'refresh': refresh_token})
        self.assertEqual(refresh_resp.status_code, status.HTTP_200_OK)
        self.assertIn('access', refresh_resp.data)

    def test_logout_blacklists_token(self):
        user = User.objects.create_user(**self.user_data)
        login_resp = self.client.post(self.login_url, {
            'email': user.email,
            'password': self.user_data['password']
        })
        access_token = login_resp.data['tokens']['access']
        refresh_token = login_resp.data['tokens']['refresh']

        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')
        logout_resp = self.client.post(self.logout_url, {'refresh': refresh_token})
        self.assertEqual(logout_resp.status_code, status.HTTP_200_OK)

        # Re-using blacklisted refresh token should fail
        refresh_resp = self.client.post(self.refresh_url, {'refresh': refresh_token})
        self.assertEqual(refresh_resp.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_password_reset_request_and_confirm(self):
        user = User.objects.create_user(**self.user_data)
        req_resp = self.client.post(self.reset_request_url, {'email': user.email})
        self.assertEqual(req_resp.status_code, status.HTTP_200_OK)

        reset_token = AuthService.generate_password_reset_token(user)
        confirm_resp = self.client.post(self.reset_confirm_url, {
            'email': user.email,
            'token': reset_token,
            'new_password': 'BrandNewPassword123!',
        })
        self.assertEqual(confirm_resp.status_code, status.HTTP_200_OK)
        self.assertEqual(confirm_resp.data['status'], 'success')

        # Check new password works
        user.refresh_from_db()
        self.assertTrue(user.check_password('BrandNewPassword123!'))

    def test_password_reset_confirm_invalid_email(self):
        confirm_resp = self.client.post(self.reset_confirm_url, {
            'email': 'nonexistent@vewra.io',
            'token': 'some-token',
            'new_password': 'BrandNewPassword123!',
        })
        self.assertEqual(confirm_resp.status_code, status.HTTP_400_BAD_REQUEST)

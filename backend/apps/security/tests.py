from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from apps.users.models import User
from apps.authentication.services import AuthService
from .models import Verification, DeviceSecurity

class SecurityTests(APITestCase):
    def setUp(self):
        self.verification_url = reverse('security-verification-status')
        self.device_url = reverse('security-device-register')

        self.user = User.objects.create_user(
            email='security.user@vewra.io',
            username='sec_user',
            password='Password123!',
        )
        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

    def test_get_verification_status(self):
        response = self.client.get(self.verification_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'success')
        self.assertEqual(response.data['verification']['verification_level'], 'BASIC')

    def test_register_device_security(self):
        payload = {
            'device_id': 'device_abc123_xyz',
            'platform': 'android',
            'app_version': '1.0.0',
            'is_vpn_detected': False,
            'is_rooted': False,
        }
        response = self.client.post(self.device_url, payload)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['device']['device_id'], 'device_abc123_xyz')
        self.assertTrue(DeviceSecurity.objects.filter(user=self.user, device_id='device_abc123_xyz').exists())

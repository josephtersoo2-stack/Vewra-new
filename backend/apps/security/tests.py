from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from apps.users.models import User
from apps.authentication.services import AuthService
from .models import Verification, DeviceSecurity, TrustScoreHistory
from .services import SecurityService

class SecurityTests(APITestCase):
    def setUp(self):
        self.verification_url = reverse('security-verification-status')
        self.verification_submit_url = reverse('security-verification-submit')
        self.trust_history_url = reverse('security-trust-history')
        self.device_url = reverse('security-device-register')

        self.user = User.objects.create_user(
            email='security.user@vewra.io',
            username='sec_user',
            password='Password123!',
            country='Nigeria',
        )
        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

    def test_get_verification_status(self):
        response = self.client.get(self.verification_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'success')
        self.assertEqual(response.data['verification']['verification_level'], 'BASIC')

    def test_submit_verification_documents(self):
        payload = {
            'country': 'Nigeria',
            'document_type': 'NATIONAL_ID',
            'document_reference': 'NIN-9876543210',
        }
        response = self.client.post(self.verification_submit_url, payload)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['verification']['status'], 'PENDING')
        self.assertEqual(response.data['verification']['document_reference'], 'NIN-9876543210')

        self.user.refresh_from_db()
        self.assertEqual(self.user.profile.verification_status, 'Pending Review')

    def test_record_and_get_trust_score_history(self):
        SecurityService.record_trust_score_change(
            user=self.user,
            new_score=85,
            reason='Completed ID verification submission',
        )
        response = self.client.get(self.trust_history_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['history']), 1)
        self.assertEqual(response.data['history'][0]['new_score'], 85)
        self.assertEqual(response.data['history'][0]['reason'], 'Completed ID verification submission')

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

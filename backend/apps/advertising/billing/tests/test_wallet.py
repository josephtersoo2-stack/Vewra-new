import uuid
from decimal import Decimal
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError

from apps.advertising.billing.models import AdvertiserWallet
from apps.advertising.billing.services import AdvertiserBillingService

User = get_user_model()


class AdvertiserWalletTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="wallet_advertiser",
            email="wallet_adv@example.com",
            password="StrongPassword123!",
        )
        self.user.role = "advertiser"
        self.user.is_advertiser = True

    def test_wallet_creation_and_defaults(self):
        wallet = AdvertiserBillingService.get_or_create_wallet(self.user)
        self.assertIsInstance(wallet.id, uuid.UUID)
        self.assertEqual(wallet.advertiser, self.user)
        self.assertEqual(wallet.balance, Decimal("0.0000"))
        self.assertEqual(wallet.total_spent, Decimal("0.0000"))
        self.assertEqual(wallet.currency, "USD")
        self.assertIn(self.user.email, str(wallet))

    def test_wallet_deposit_and_deduct(self):
        wallet = AdvertiserBillingService.get_or_create_wallet(self.user)
        
        # Deposit $50.00
        new_balance = wallet.deposit(Decimal("50.00"))
        self.assertEqual(new_balance, Decimal("50.0000"))
        self.assertEqual(wallet.balance, Decimal("50.0000"))

        # Deduct $10.00
        deducted = wallet.deduct(Decimal("10.00"))
        self.assertTrue(deducted)
        self.assertEqual(wallet.balance, Decimal("40.0000"))
        self.assertEqual(wallet.total_spent, Decimal("10.0000"))

    def test_negative_balance_prevention(self):
        wallet = AdvertiserBillingService.get_or_create_wallet(self.user)
        wallet.deposit(Decimal("5.00"))

        # Attempt to deduct $10.00 with only $5.00 balance
        deducted = wallet.deduct(Decimal("10.00"))
        self.assertFalse(deducted)
        self.assertEqual(wallet.balance, Decimal("5.0000"))
        self.assertEqual(wallet.total_spent, Decimal("0.0000"))

    def test_fund_wallet_service(self):
        wallet = AdvertiserBillingService.fund_wallet(self.user, Decimal("100.00"))
        self.assertEqual(wallet.balance, Decimal("100.0000"))

        with self.assertRaises(ValidationError):
            AdvertiserBillingService.fund_wallet(self.user, Decimal("-10.00"))

from decimal import Decimal
from django.urls import reverse
from django.core.exceptions import ValidationError
from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth import get_user_model
from apps.authentication.services import AuthService
from .models import (
    Wallet,
    CoinTransaction,
    CashTransaction,
    WithdrawalRequest,
    CoinTransactionType,
    CashTransactionType,
    CashTransactionStatus,
    WithdrawalMethod,
    WithdrawalStatus,
)
from .services import WalletService

User = get_user_model()

class WalletTests(APITestCase):
    def setUp(self):
        self.balance_url = reverse('wallet-balance')
        self.tx_url = reverse('wallet-transactions')
        self.coin_history_url = reverse('wallet-coins-history')
        self.transfer_url = reverse('wallet-coins-transfer')
        self.withdrawals_url = reverse('wallet-withdrawals-list')
        self.withdraw_create_url = reverse('wallet-withdrawals-create')

        self.user = User.objects.create_user(
            email='wallet.user@vewra.io',
            username='wallet_user',
            password='Password123!',
            currency='USD',
        )
        self.recipient = User.objects.create_user(
            email='recipient@vewra.io',
            username='recipient_user',
            password='Password123!',
        )

        self.tokens = AuthService.get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.tokens['access']}")

    def test_wallet_auto_created(self):
        self.assertTrue(hasattr(self.user, 'wallet'))
        self.assertEqual(self.user.wallet.coin_balance, 0)
        self.assertEqual(self.user.wallet.cash_balance, Decimal('0.00'))

    def test_get_wallet_balance_api(self):
        response = self.client.get(self.balance_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'success')
        self.assertEqual(response.data['wallet']['coin_balance'], 0)
        self.assertEqual(response.data['wallet']['currency'], 'USD')

    def test_universal_create_transaction_service(self):
        # 1. Test Coin Transaction creation via universal helper
        coin_tx = WalletService.create_transaction(
            user=self.user,
            transaction_type=CoinTransactionType.BONUS,
            amount=300,
            reference='REF-BONUS-01',
            description='Daily login streak bonus',
            transaction_category='COIN',
            balance_before=0,
            balance_after=300,
        )
        self.assertEqual(coin_tx.amount, 300)
        self.assertEqual(coin_tx.balance_before, 0)
        self.assertEqual(coin_tx.balance_after, 300)
        self.assertEqual(coin_tx.reference, 'REF-BONUS-01')

        # 2. Test Cash Transaction creation via universal helper
        cash_tx = WalletService.create_transaction(
            user=self.user,
            transaction_type=CashTransactionType.REWARD,
            amount=Decimal('5.00'),
            currency='USD',
            reference='REF-CASH-01',
            description='Survey completion fiat reward',
            transaction_category='CASH',
            status=CashTransactionStatus.COMPLETED,
        )
        self.assertEqual(cash_tx.amount, Decimal('5.00'))
        self.assertEqual(cash_tx.status, CashTransactionStatus.COMPLETED)
        self.assertEqual(cash_tx.reference, 'REF-CASH-01')

    def test_credit_and_deduct_coins_services(self):
        # 1. Credit 500 Coins
        wallet, tx = WalletService.credit_coins(
            user=self.user,
            amount=500,
            transaction_type=CoinTransactionType.REWARD,
            description='Watched sponsored tech video',
        )
        self.assertEqual(wallet.coin_balance, 500)
        self.assertEqual(wallet.cash_balance, Decimal('5.00'))
        self.assertEqual(tx.balance_after, 500)
        self.assertEqual(CoinTransaction.objects.filter(user=self.user).count(), 1)

        # 2. Deduct 200 Coins
        wallet, tx2 = WalletService.deduct_coins(
            user=self.user,
            amount=200,
            transaction_type=CoinTransactionType.PURCHASE,
            description='Redeemed discount coupon',
        )
        self.assertEqual(wallet.coin_balance, 300)
        self.assertEqual(wallet.cash_balance, Decimal('3.00'))
        self.assertEqual(tx2.balance_after, 300)
        self.assertEqual(CoinTransaction.objects.filter(user=self.user).count(), 2)

    def test_prevent_negative_balances(self):
        WalletService.credit_coins(user=self.user, amount=100)
        with self.assertRaises(ValidationError):
            WalletService.deduct_coins(user=self.user, amount=200)

        # Confirm balance remains uncorrupted
        wallet = Wallet.objects.get(user=self.user)
        self.assertEqual(wallet.coin_balance, 100)

    def test_security_extension_hooks(self):
        ver_check = WalletService.check_verification_status(self.user)
        self.assertIn("approved", ver_check)

        trust_check = WalletService.check_trust_score(self.user, required_score=40)
        self.assertTrue(trust_check["approved"])

        limit_check = WalletService.check_withdrawal_limit(self.user, Decimal('100.00'))
        self.assertTrue(limit_check["approved"])

        fraud_check = WalletService.run_financial_fraud_checks(
            self.user,
            amount=Decimal('50.00'),
            method='USDT',
            destination='TRX123456789',
        )
        self.assertTrue(fraud_check["approved"])

    def test_coin_transfer_api(self):
        WalletService.credit_coins(user=self.user, amount=1000)

        payload = {
            'recipient_username': 'recipient_user',
            'amount': 400,
            'description': 'Payment for design asset',
        }
        response = self.client.post(self.transfer_url, payload)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['wallet']['coin_balance'], 600)

        # Verify recipient received funds
        self.recipient.refresh_from_db()
        self.assertEqual(self.recipient.wallet.coin_balance, 400)

    def test_withdrawal_foundation_flow(self):
        # 1. Fund user balance: 5,000 Coins = $50.00
        WalletService.credit_coins(user=self.user, amount=5000)

        # 2. Request $25.00 USDT withdrawal
        payload = {
            'amount': '25.00',
            'method': WithdrawalMethod.USDT,
            'destination': 'TXz981jkhdasduihasdu1238912',
        }
        response = self.client.post(self.withdraw_create_url, payload)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['withdrawal']['amount'], '25.00')
        self.assertEqual(response.data['withdrawal']['status'], WithdrawalStatus.PENDING)

        # Crucial Phase 4 Foundation Rule: Balance is NOT immediately deducted at creation
        self.assertEqual(response.data['wallet']['coin_balance'], 5000)

        # 3. Check withdrawal listing
        list_resp = self.client.get(self.withdrawals_url)
        self.assertEqual(list_resp.status_code, status.HTTP_200_OK)
        self.assertEqual(len(list_resp.data['withdrawals']), 1)

        # 4. Verify future execution helper deducts balance upon completion
        withdrawal_id = response.data['withdrawal']['id']
        processed_wd = WalletService.execute_processed_withdrawal(withdrawal_id)
        self.assertEqual(processed_wd.status, WithdrawalStatus.COMPLETED)

        self.user.wallet.refresh_from_db()
        self.assertEqual(self.user.wallet.coin_balance, 2500)

    def test_withdrawal_insufficient_funds(self):
        payload = {
            'amount': '500.00',
            'method': WithdrawalMethod.BANK,
            'destination': 'US-IBAN-123456',
        }
        response = self.client.post(self.withdraw_create_url, payload)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('Insufficient funds', response.data['message'])

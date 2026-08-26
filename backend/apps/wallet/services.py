import uuid
from decimal import Decimal
from django.db import transaction
from django.utils import timezone
from django.core.exceptions import ValidationError
from django.contrib.auth import get_user_model
from .models import (
    Wallet,
    CoinTransaction,
    CoinTransactionType,
    CashTransaction,
    CashTransactionType,
    CashTransactionStatus,
    WithdrawalRequest,
    WithdrawalMethod,
    WithdrawalStatus,
)

User = get_user_model()

class WalletService:
    COIN_TO_FIAT_RATE = Decimal('0.01')  # 100 Coins = $1.00 USD

    @staticmethod
    def get_or_create_wallet(user):
        """Fetch or create a wallet instance for the specified user."""
        wallet, _ = Wallet.objects.get_or_create(
            user=user,
            defaults={
                'currency': getattr(user, 'currency', 'USD') or 'USD',
                'coin_balance': 0,
                'cash_balance': Decimal('0.00'),
                'pending_cash': Decimal('0.00'),
                'pending_coins': 0,
                'lifetime_coins': 0,
                'lifetime_cash': Decimal('0.00'),
            }
        )
        return wallet

    @staticmethod
    def get_wallet_balance(user):
        """Retrieve aggregated wallet balance summary for a user."""
        wallet = WalletService.get_or_create_wallet(user)
        return {
            'coin_balance': wallet.coin_balance,
            'cash_balance': wallet.cash_balance,
            'pending_cash': wallet.pending_cash,
            'pending_coins': wallet.pending_coins,
            'lifetime_coins': wallet.lifetime_coins,
            'lifetime_cash': wallet.lifetime_cash,
            'currency': wallet.currency,
        }

    @staticmethod
    @transaction.atomic
    def credit_coins(user, amount: int, transaction_type: str = CoinTransactionType.REWARD, reference: str = None, description: str = ''):
        """Credit coins to a user's wallet and write immutable audit transaction."""
        if amount <= 0:
            raise ValidationError("Coin credit amount must be positive.")

        wallet = Wallet.objects.select_for_update().get_or_create(
            user=user,
            defaults={'currency': getattr(user, 'currency', 'USD') or 'USD'}
        )[0]

        balance_before = wallet.coin_balance
        wallet.coin_balance += amount
        wallet.lifetime_coins += amount
        wallet.cash_balance = Decimal(str(wallet.coin_balance * WalletService.COIN_TO_FIAT_RATE))
        wallet.lifetime_cash = Decimal(str(wallet.lifetime_coins * WalletService.COIN_TO_FIAT_RATE))
        wallet.save()

        ref = reference or f"COIN-CR-{uuid.uuid4().hex[:12].upper()}"
        desc = description or f"Credited {amount} Coins via {transaction_type}"

        coin_tx = CoinTransaction.objects.create(
            user=user,
            transaction_type=transaction_type,
            amount=amount,
            balance_before=balance_before,
            balance_after=wallet.coin_balance,
            reference=ref,
            description=desc,
        )
        return wallet, coin_tx

    @staticmethod
    @transaction.atomic
    def deduct_coins(user, amount: int, transaction_type: str = CoinTransactionType.ADJUSTMENT, reference: str = None, description: str = ''):
        """Deduct coins from a user's wallet with balance validation."""
        if amount <= 0:
            raise ValidationError("Coin deduction amount must be positive.")

        wallet = Wallet.objects.select_for_update().get_or_create(
            user=user,
            defaults={'currency': getattr(user, 'currency', 'USD') or 'USD'}
        )[0]

        if wallet.coin_balance < amount:
            raise ValidationError(f"Insufficient coin balance. Available: {wallet.coin_balance}, Requested: {amount}")

        balance_before = wallet.coin_balance
        wallet.coin_balance -= amount
        wallet.cash_balance = Decimal(str(wallet.coin_balance * WalletService.COIN_TO_FIAT_RATE))
        wallet.save()

        ref = reference or f"COIN-DR-{uuid.uuid4().hex[:12].upper()}"
        desc = description or f"Deducted {amount} Coins via {transaction_type}"

        coin_tx = CoinTransaction.objects.create(
            user=user,
            transaction_type=transaction_type,
            amount=-amount,
            balance_before=balance_before,
            balance_after=wallet.coin_balance,
            reference=ref,
            description=desc,
        )
        return wallet, coin_tx

    @staticmethod
    @transaction.atomic
    def credit_cash(user, amount: Decimal, transaction_type: str = CashTransactionType.REWARD, reference: str = None, description: str = '', status: str = CashTransactionStatus.COMPLETED):
        """Credit fiat cash balance directly."""
        amount = Decimal(str(amount))
        if amount <= 0:
            raise ValidationError("Cash credit amount must be positive.")

        wallet = Wallet.objects.select_for_update().get_or_create(
            user=user,
            defaults={'currency': getattr(user, 'currency', 'USD') or 'USD'}
        )[0]

        if status == CashTransactionStatus.COMPLETED:
            wallet.cash_balance += amount
            wallet.lifetime_cash += amount
        elif status == CashTransactionStatus.PENDING:
            wallet.pending_cash += amount
        wallet.save()

        ref = reference or f"CASH-CR-{uuid.uuid4().hex[:12].upper()}"
        desc = description or f"Cash credit of ${amount} {wallet.currency}"

        cash_tx = CashTransaction.objects.create(
            user=user,
            transaction_type=transaction_type,
            amount=amount,
            currency=wallet.currency,
            status=status,
            reference=ref,
            description=desc,
        )
        return wallet, cash_tx

    @staticmethod
    @transaction.atomic
    def transfer_coins(sender, recipient_username: str, amount: int, description: str = ''):
        """Perform P2P coin transfer between two users with double-entry audit records."""
        if sender.username == recipient_username:
            raise ValidationError("Cannot transfer coins to your own account.")

        if amount <= 0:
            raise ValidationError("Transfer amount must be greater than zero.")

        try:
            recipient = User.objects.get(username=recipient_username)
        except User.DoesNotExist:
            raise ValidationError(f"Recipient user '@{recipient_username}' not found.")

        # Deduct from sender
        ref = f"P2P-{uuid.uuid4().hex[:10].upper()}"
        desc_sender = description or f"Transfer to @{recipient.username}"
        WalletService.deduct_coins(
            user=sender,
            amount=amount,
            transaction_type=CoinTransactionType.TRANSFER,
            reference=ref,
            description=desc_sender,
        )

        # Credit to recipient
        desc_recipient = f"Received from @{sender.username}: {description}" if description else f"Received from @{sender.username}"
        WalletService.credit_coins(
            user=recipient,
            amount=amount,
            transaction_type=CoinTransactionType.TRANSFER,
            reference=ref,
            description=desc_recipient,
        )
        return ref

    @staticmethod
    @transaction.atomic
    def create_withdrawal_request(user, amount: Decimal, method: str, destination: str):
        """Create a withdrawal request and deduct the corresponding coin/fiat balance."""
        amount = Decimal(str(amount))
        if amount <= Decimal('0.00'):
            raise ValidationError("Withdrawal amount must be greater than zero.")

        # 100 Coins = $1.00 USD
        coins_needed = int(amount / WalletService.COIN_TO_FIAT_RATE)

        wallet = WalletService.get_or_create_wallet(user)
        if wallet.coin_balance < coins_needed and wallet.cash_balance < amount:
            raise ValidationError(f"Insufficient funds. Required: {coins_needed} Coins (${amount}), Available: {wallet.coin_balance} Coins (${wallet.cash_balance})")

        # Deduct coins from user balance
        ref = f"WD-{uuid.uuid4().hex[:10].upper()}"
        WalletService.deduct_coins(
            user=user,
            amount=coins_needed,
            transaction_type=CoinTransactionType.WITHDRAWAL,
            reference=ref,
            description=f"Withdrawal request of ${amount} via {method}",
        )

        # Create Withdrawal Request entry
        withdrawal = WithdrawalRequest.objects.create(
            user=user,
            amount=amount,
            coins_deducted=coins_needed,
            currency=wallet.currency,
            method=method,
            status=WithdrawalStatus.PENDING,
            destination=destination,
        )

        # Create Cash Transaction entry
        CashTransaction.objects.create(
            user=user,
            transaction_type=CashTransactionType.WITHDRAWAL,
            amount=-amount,
            currency=wallet.currency,
            status=CashTransactionStatus.PENDING,
            reference=ref,
            description=f"Pending payout to {destination} ({method})",
        )

        return withdrawal

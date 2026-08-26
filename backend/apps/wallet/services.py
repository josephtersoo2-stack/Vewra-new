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

    # =========================================================================
    # Universal Transaction Service
    # =========================================================================
    @staticmethod
    @transaction.atomic
    def create_transaction(
        user,
        transaction_type: str,
        amount,
        currency: str = 'USD',
        reference: str = None,
        description: str = '',
        transaction_category: str = 'COIN',  # 'COIN' or 'CASH'
        status: str = CashTransactionStatus.COMPLETED,
        balance_before: int = None,
        balance_after: int = None,
    ):
        """
        Universal transaction creation service for all VEWRA subsystems.
        Supports Coins and Cash transactions, automatically generating references,
        capturing balance snapshots, and preserving full audit logs.
        """
        wallet = WalletService.get_or_create_wallet(user)
        ref = reference or f"TX-{uuid.uuid4().hex[:12].upper()}"

        if transaction_category.upper() == 'COIN':
            int_amount = int(amount)
            b_before = balance_before if balance_before is not None else wallet.coin_balance
            b_after = balance_after if balance_after is not None else (b_before + int_amount)

            return CoinTransaction.objects.create(
                user=user,
                transaction_type=transaction_type,
                amount=int_amount,
                balance_before=b_before,
                balance_after=b_after,
                reference=ref,
                description=description or f"Coin {transaction_type} of {int_amount} Coins",
            )
        else:
            dec_amount = Decimal(str(amount))
            return CashTransaction.objects.create(
                user=user,
                transaction_type=transaction_type,
                amount=dec_amount,
                currency=currency or wallet.currency,
                status=status,
                reference=ref,
                description=description or f"Cash {transaction_type} of ${dec_amount} {currency}",
            )

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

        coin_tx = WalletService.create_transaction(
            user=user,
            transaction_type=transaction_type,
            amount=amount,
            reference=ref,
            description=desc,
            transaction_category='COIN',
            balance_before=balance_before,
            balance_after=wallet.coin_balance,
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

        coin_tx = WalletService.create_transaction(
            user=user,
            transaction_type=transaction_type,
            amount=-amount,
            reference=ref,
            description=desc,
            transaction_category='COIN',
            balance_before=balance_before,
            balance_after=wallet.coin_balance,
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

        cash_tx = WalletService.create_transaction(
            user=user,
            transaction_type=transaction_type,
            amount=amount,
            currency=wallet.currency,
            status=status,
            reference=ref,
            description=desc,
            transaction_category='CASH',
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

    # =========================================================================
    # Security Extension Points
    # =========================================================================
    @staticmethod
    def check_verification_status(user) -> dict:
        """
        Security extension hook for user KYC verification status.
        """
        status = getattr(user, 'verification_status', 'Basic')
        verification = getattr(user, 'verification', None)
        is_verified = (status in ['Verified', 'Trusted']) or (verification and verification.status == 'APPROVED')
        return {
            "approved": is_verified,
            "status": status,
            "reason": "User verification requirements met" if is_verified else "Verification pending or basic level"
        }

    @staticmethod
    def check_trust_score(user, required_score: int = 50) -> dict:
        """
        Security extension hook for user trust score compliance.
        """
        score = getattr(user, 'trust_score', 80)
        passed = score >= required_score
        return {
            "approved": passed,
            "trust_score": score,
            "required_score": required_score,
            "reason": "Trust score satisfies minimum security threshold" if passed else f"Trust score ({score}) below required ({required_score})"
        }

    @staticmethod
    def check_withdrawal_limit(user, amount: Decimal) -> dict:
        """
        Security extension hook for user withdrawal limits.
        """
        amount = Decimal(str(amount))
        max_limit = Decimal('5000.00')
        passed = amount <= max_limit
        return {
            "approved": passed,
            "requested_amount": str(amount),
            "max_limit": str(max_limit),
            "reason": "Withdrawal amount within allowed limits" if passed else f"Requested amount exceeds tier limit of ${max_limit}"
        }

    @staticmethod
    def run_financial_fraud_checks(user, amount: Decimal, method: str, destination: str) -> dict:
        """
        Security extension hook for anti-fraud and risk analysis.
        """
        if not destination or len(destination.strip()) < 4:
            return {
                "approved": False,
                "risk_score": 90,
                "reason": "Invalid or incomplete destination address/account details."
            }
        return {
            "approved": True,
            "risk_score": 10,
            "reason": "Passed initial wallet checks"
        }

    # =========================================================================
    # Withdrawal Foundation (Creation without immediate balance deduction)
    # =========================================================================
    @staticmethod
    @transaction.atomic
    def create_withdrawal_request(user, amount: Decimal, method: str, destination: str):
        """
        Create a withdrawal request foundation in PENDING status.
        Runs security hooks, verifies sufficient balance, and queues the request
        without immediate financial balance deduction (which is handled upon future payout processing).
        """
        amount = Decimal(str(amount))
        if amount <= Decimal('0.00'):
            raise ValidationError("Withdrawal amount must be greater than zero.")

        # 1. Run Security Extension Points
        fraud_check = WalletService.run_financial_fraud_checks(user, amount, method, destination)
        if not fraud_check["approved"]:
            raise ValidationError(fraud_check["reason"])

        limit_check = WalletService.check_withdrawal_limit(user, amount)
        if not limit_check["approved"]:
            raise ValidationError(limit_check["reason"])

        # 2. Check balance availability (100 Coins = $1.00 USD)
        coins_needed = int(amount / WalletService.COIN_TO_FIAT_RATE)
        wallet = WalletService.get_or_create_wallet(user)
        if wallet.coin_balance < coins_needed and wallet.cash_balance < amount:
            raise ValidationError(
                f"Insufficient funds. Required: {coins_needed} Coins (${amount}), Available: {wallet.coin_balance} Coins (${wallet.cash_balance})"
            )

        # 3. Create Withdrawal Request in PENDING state (NO immediate balance deduction)
        withdrawal = WithdrawalRequest.objects.create(
            user=user,
            amount=amount,
            coins_deducted=coins_needed,
            currency=wallet.currency,
            method=method,
            status=WithdrawalStatus.PENDING,
            destination=destination,
        )

        return withdrawal

    @staticmethod
    @transaction.atomic
    def execute_processed_withdrawal(withdrawal_id: int):
        """
        Execution hook for future verification and payout engines (Phase 8) to finalize payout and deduct funds.
        """
        withdrawal = WithdrawalRequest.objects.select_for_update().get(id=withdrawal_id)
        if withdrawal.status != WithdrawalStatus.PENDING:
            raise ValidationError(f"Withdrawal #{withdrawal_id} is already in {withdrawal.status} status.")

        ref = f"WD-{uuid.uuid4().hex[:10].upper()}"
        WalletService.deduct_coins(
            user=withdrawal.user,
            amount=withdrawal.coins_deducted,
            transaction_type=CoinTransactionType.WITHDRAWAL,
            reference=ref,
            description=f"Processed withdrawal #{withdrawal.id} via {withdrawal.method}",
        )

        # Write Cash transaction record
        WalletService.create_transaction(
            user=withdrawal.user,
            transaction_type=CashTransactionType.WITHDRAWAL,
            amount=-withdrawal.amount,
            currency=withdrawal.currency,
            status=CashTransactionStatus.COMPLETED,
            reference=ref,
            description=f"Completed payout to {withdrawal.destination} ({withdrawal.method})",
            transaction_category='CASH',
        )

        withdrawal.status = WithdrawalStatus.COMPLETED
        withdrawal.processed_at = timezone.now()
        withdrawal.save()
        return withdrawal

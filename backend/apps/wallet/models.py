import uuid
from django.db import models
from django.conf import settings

class CoinTransactionType(models.TextChoices):
    REWARD = 'REWARD', 'Reward'
    PURCHASE = 'PURCHASE', 'Purchase'
    SALE = 'SALE', 'Sale'
    PROMOTION = 'PROMOTION', 'Promotion'
    BONUS = 'BONUS', 'Bonus'
    ADJUSTMENT = 'ADJUSTMENT', 'Adjustment'
    TRANSFER = 'TRANSFER', 'Transfer'
    WITHDRAWAL = 'WITHDRAWAL', 'Withdrawal'


class CashTransactionStatus(models.TextChoices):
    PENDING = 'PENDING', 'Pending'
    COMPLETED = 'COMPLETED', 'Completed'
    FAILED = 'FAILED', 'Failed'
    CANCELLED = 'CANCELLED', 'Cancelled'


class CashTransactionType(models.TextChoices):
    DEPOSIT = 'DEPOSIT', 'Deposit'
    WITHDRAWAL = 'WITHDRAWAL', 'Withdrawal'
    CONVERSION = 'CONVERSION', 'Conversion'
    REWARD = 'REWARD', 'Reward'
    PURCHASE = 'PURCHASE', 'Purchase'
    ADJUSTMENT = 'ADJUSTMENT', 'Adjustment'


class WithdrawalMethod(models.TextChoices):
    BANK = 'BANK', 'Direct Bank Wire'
    CRYPTO = 'CRYPTO', 'Cryptocurrency'
    USDT = 'USDT', 'USDT (TRC-20 / BEP-20)'
    GIFTCARD = 'GIFTCARD', 'Digital Gift Card'
    PAYPAL = 'PAYPAL', 'PayPal Transfer'


class WithdrawalStatus(models.TextChoices):
    PENDING = 'PENDING', 'Pending'
    PROCESSING = 'PROCESSING', 'Processing'
    COMPLETED = 'COMPLETED', 'Completed'
    REJECTED = 'REJECTED', 'Rejected'
    CANCELLED = 'CANCELLED', 'Cancelled'


class Wallet(models.Model):
    """Core financial wallet entity storing dual balances (Coins & Fiat Cash)."""

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='wallet'
    )
    coin_balance = models.PositiveBigIntegerField(default=0)
    cash_balance = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    pending_cash = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    pending_coins = models.PositiveIntegerField(default=0)
    lifetime_coins = models.PositiveBigIntegerField(default=0)
    lifetime_cash = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    currency = models.CharField(max_length=10, default='USD')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vewra_wallets'
        verbose_name = 'User Wallet'
        verbose_name_plural = 'User Wallets'

    def __str__(self):
        return f"{self.user.username}'s Wallet ({self.coin_balance} Coins | ${self.cash_balance} {self.currency})"


class CoinTransaction(models.Model):
    """Audit log of all VEWRA Coin balance adjustments, transfers, and task rewards."""

    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='coin_transactions'
    )
    transaction_type = models.CharField(
        max_length=20,
        choices=CoinTransactionType.choices,
        default=CoinTransactionType.REWARD
    )
    amount = models.BigIntegerField(
        help_text='Positive for credit, negative for debit'
    )
    balance_before = models.PositiveBigIntegerField()
    balance_after = models.PositiveBigIntegerField()
    reference = models.CharField(max_length=100, db_index=True)
    description = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'vewra_coin_transactions'
        verbose_name = 'Coin Transaction'
        verbose_name_plural = 'Coin Transactions'
        ordering = ['-created_at']

    def __str__(self):
        return f"[{self.transaction_type}] {self.user.username}: {self.amount:+d} Coins"


class CashTransaction(models.Model):
    """Audit log of all fiat cash adjustments, earnings, payouts, and deposit entries."""

    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='cash_transactions'
    )
    transaction_type = models.CharField(
        max_length=20,
        choices=CashTransactionType.choices,
        default=CashTransactionType.REWARD
    )
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    currency = models.CharField(max_length=10, default='USD')
    status = models.CharField(
        max_length=20,
        choices=CashTransactionStatus.choices,
        default=CashTransactionStatus.PENDING
    )
    reference = models.CharField(max_length=100, db_index=True)
    description = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'vewra_cash_transactions'
        verbose_name = 'Cash Transaction'
        verbose_name_plural = 'Cash Transactions'
        ordering = ['-created_at']

    def __str__(self):
        return f"[{self.status}] {self.user.username}: ${self.amount} {self.currency}"


class WithdrawalRequest(models.Model):
    """User payout request queue and state."""

    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='withdrawal_requests'
    )
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    coins_deducted = models.PositiveIntegerField(default=0)
    currency = models.CharField(max_length=10, default='USD')
    method = models.CharField(
        max_length=20,
        choices=WithdrawalMethod.choices,
        default=WithdrawalMethod.USDT
    )
    status = models.CharField(
        max_length=20,
        choices=WithdrawalStatus.choices,
        default=WithdrawalStatus.PENDING
    )
    destination = models.CharField(
        max_length=255,
        help_text='Recipient wallet address, IBAN, account number or PayPal email'
    )
    admin_notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    processed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'vewra_withdrawal_requests'
        verbose_name = 'Withdrawal Request'
        verbose_name_plural = 'Withdrawal Requests'
        ordering = ['-created_at']

    def __str__(self):
        return f"Withdrawal #{self.id}: {self.user.username} - ${self.amount} {self.currency} via {self.method} ({self.status})"


class DepositRecord(models.Model):
    """User deposit and purchase log foundation."""

    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='deposits'
    )
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    currency = models.CharField(max_length=10, default='USD')
    payment_method = models.CharField(max_length=50)
    status = models.CharField(
        max_length=20,
        choices=CashTransactionStatus.choices,
        default=CashTransactionStatus.PENDING
    )
    reference = models.CharField(max_length=100, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'vewra_deposit_records'
        verbose_name = 'Deposit Record'
        verbose_name_plural = 'Deposit Records'
        ordering = ['-created_at']

    def __str__(self):
        return f"Deposit #{self.id}: {self.user.username} - ${self.amount} {self.currency} ({self.status})"

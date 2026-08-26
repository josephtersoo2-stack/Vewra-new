# VEWRA Phase 4 Wallet, Economy & Financial Foundation Implementation Plan

## Phase Purpose

Phase 4 creates the VEWRA financial foundation.

Previous phases created: - Application shell and ecosystem UI -
Authentication and user identity - Profile, verification, trust and
subscription foundations

This phase introduces the real economy layer:

-   Wallet balances
-   Coins
-   Cash balance
-   Transactions
-   Withdrawal preparation
-   Deposit preparation
-   Financial history

This phase does not connect real payment providers yet.

## Development Workflow

Follow:

Database models ↓ Backend services ↓ API endpoints ↓ Flutter integration
↓ Testing ↓ Documentation update

Every financial feature must be connected from database to mobile
application.

------------------------------------------------------------------------

# Backend Requirements

Technology:

-   Python
-   Django
-   Django REST Framework
-   Django ORM

Database:

Local: - MySQL

Production: - PostgreSQL

Do not use raw SQL.

------------------------------------------------------------------------

# Create Wallet App

Create:

    backend/apps/wallet/

Files:

    models.py
    serializers.py
    views.py
    urls.py
    services.py
    tests.py
    admin.py

------------------------------------------------------------------------

# Database Models

## Wallet

Location:

    backend/apps/wallet/models.py

Fields:

    user
    coin_balance
    cash_balance
    pending_cash
    currency
    created_at
    updated_at

------------------------------------------------------------------------

## CoinTransaction

Fields:

    user
    transaction_type
    amount
    balance_before
    balance_after
    reference
    description
    created_at

Types:

    REWARD
    PURCHASE
    SALE
    PROMOTION
    BONUS
    ADJUSTMENT

------------------------------------------------------------------------

## CashTransaction

Fields:

    user
    transaction_type
    amount
    currency
    status
    reference
    description
    created_at

Statuses:

    PENDING
    COMPLETED
    FAILED
    CANCELLED

------------------------------------------------------------------------

## WithdrawalRequest

Fields:

    user
    amount
    currency
    method
    status
    destination
    created_at
    processed_at

Methods:

    BANK
    CRYPTO
    USDT
    GIFTCARD

Only create the foundation. Do not connect payout systems.

------------------------------------------------------------------------

## DepositRecord

Fields:

    user
    amount
    currency
    payment_method
    status
    reference
    created_at

------------------------------------------------------------------------

# Wallet Services

Create:

    backend/apps/wallet/services.py

Required functions:

    credit_coins()
    deduct_coins()
    credit_cash()
    create_transaction()
    get_wallet_balance()

All balance changes must go through services.

Do not update balances directly from API views.

------------------------------------------------------------------------

# Security Requirements

Every financial action must:

-   Require authentication
-   Create transaction records
-   Preserve history
-   Prevent negative balances

Prepare extension points for:

-   Fraud checks
-   Trust score checks
-   Verification checks
-   Withdrawal limits

------------------------------------------------------------------------

# API Endpoints

Create:

    /api/v1/wallet/

Required:

    GET /balance/

    GET /transactions/

    GET /coins/history/

    POST /coins/transfer/

    GET /withdrawals/

    POST /withdrawals/create/

No payment execution.

------------------------------------------------------------------------

# Flutter Integration

Create or extend:

    mobile/lib/features/wallet/

Add:

    data/
    wallet_api_service.dart
    wallet_repository.dart

    models/
    wallet_model.dart
    transaction_model.dart

    providers/
    wallet_provider.dart

    screens/
    wallet_screen.dart
    transaction_history_screen.dart
    withdraw_screen.dart

Replace dummy wallet data with API data.

------------------------------------------------------------------------

# Testing

Backend:

-   Wallet creation
-   Balance retrieval
-   Coin credit
-   Coin deduction
-   Transaction history
-   Withdrawal creation

Flutter:

-   Wallet provider
-   Wallet rendering
-   Transaction history
-   Withdrawal screen

------------------------------------------------------------------------

# Completion Criteria

Phase 4 is complete when:

-   Wallet database exists
-   Transactions are recorded
-   Balance changes use services
-   APIs work
-   Flutter displays real wallet data
-   Withdrawal foundation exists
-   Tests pass

------------------------------------------------------------------------

# Restrictions

Do not build:

-   Payment gateways
-   Crypto providers
-   Bank integrations
-   Coin marketplace
-   Promotion payments
-   Reward calculation engine

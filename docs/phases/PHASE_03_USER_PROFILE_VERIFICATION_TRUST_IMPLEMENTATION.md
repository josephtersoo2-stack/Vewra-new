# VEWRA Phase 3 User Profile, Verification & Trust Foundation Implementation Plan

## Phase Purpose

Phase 3 builds the complete user identity experience on top of the
authentication foundation completed in Phase 2.

Phase 2 created:

-   User accounts
-   Authentication
-   JWT sessions
-   Basic profile storage
-   Security preparation

Phase 3 now turns the account into a complete VEWRA user identity
system.

This phase does not build the full financial verification system or
withdrawal system yet. It creates the foundation required for those
systems.

The purpose is to make every user understandable by the platform:

-   Who is the user?
-   What country are they from?
-   What currency do they use?
-   What level are they?
-   What is their trust score?
-   Are they verified?
-   What features can they access?
-   What subscription do they have?

------------------------------------------------------------------------

# Development Method

Follow the VEWRA development workflow:

UI Template ↓ Backend Models ↓ API Endpoints ↓ Flutter Integration ↓
Testing ↓ Documentation Update

Every feature added must be connected from database to mobile
application.

------------------------------------------------------------------------

# Technology Requirements

## Backend

Continue:

-   Python
-   Django
-   Django REST Framework
-   Django ORM

Database:

Local:

-   MySQL

Production:

-   PostgreSQL

Do not use raw SQL.

------------------------------------------------------------------------

## Mobile

Continue:

-   Flutter
-   Riverpod
-   Dio
-   Secure Storage

Preserve the Phase 1 and Phase 2 architecture.

------------------------------------------------------------------------

# Backend Structure

Create or extend:

    backend/apps/users/

    backend/apps/security/

    backend/apps/subscriptions/

------------------------------------------------------------------------

# User Profile System

## Database Models

Update:

    backend/apps/users/models.py

Extend UserProfile.

Required fields:

    user

    display_name

    avatar

    bio

    country

    city

    language

    currency

    timezone

    date_of_birth

    gender

    level

    xp

    trust_score

    verification_status

    subscription_tier

    created_at

    updated_at

Purpose:

Store the user's public and ecosystem identity.

------------------------------------------------------------------------

# Profile Preferences Model

Create:

    backend/apps/users/models.py

Model:

    UserPreference

Fields:

    user

    theme

    language

    notification_enabled

    email_notifications

    push_notifications

    created_at

    updated_at

------------------------------------------------------------------------

# User Statistics Model

Create:

    backend/apps/users/models.py

Model:

    UserStatistics

Fields:

    user

    tasks_completed

    videos_watched

    quizzes_completed

    comments_created

    referrals

    total_rewards

    created_at

    updated_at

These values will later connect to gamification.

------------------------------------------------------------------------

# Verification Foundation

Extend:

    backend/apps/security/models.py

The verification system must prepare for worldwide verification.

Fields:

    user

    country

    verification_level

    status

    document_type

    document_reference

    submitted_at

    reviewed_at

    approved_at

    rejection_reason

Statuses:

    NOT_STARTED

    PENDING

    APPROVED

    REJECTED

Do not integrate external KYC providers yet.

------------------------------------------------------------------------

# Trust Score Foundation

Create:

    backend/apps/security/models.py

Model:

    TrustScoreHistory

Fields:

    user

    previous_score

    new_score

    reason

    created_at

Purpose:

Track future changes caused by:

-   Account behaviour
-   Verification
-   Fraud checks
-   Platform activity

Do not create automatic scoring algorithms yet.

------------------------------------------------------------------------

# User Permissions Foundation

Create service layer:

    backend/apps/users/services.py

Prepare functions:

    can_sell_coins(user)

    can_withdraw(user)

    can_access_creator_tools(user)

    can_access_marketplace_features(user)

For now return based on placeholder rules.

Future phases will replace them with real rules.

------------------------------------------------------------------------

# Subscription Foundation

Create:

    backend/apps/subscriptions/

Files:

    models.py

    serializers.py

    views.py

    urls.py

    services.py

    tests.py

Create:

    SubscriptionTier

Fields:

    name

    description

    monthly_price

    annual_price

    benefits

    active

    created_at

Initial tiers:

    FREE

    PREMIUM

    PRO

No payment integration.

------------------------------------------------------------------------

# API Endpoints

Create:

    /api/v1/users/

Endpoints:

## Profile

    GET /profile/

    PATCH /profile/update/

## Public Profile

    GET /profile/{username}/

## Statistics

    GET /profile/statistics/

## Preferences

    GET /preferences/

    PATCH /preferences/update/

------------------------------------------------------------------------

# Verification API

Create:

    /api/v1/security/

Endpoints:

    GET /verification/status/

    POST /verification/submit/

------------------------------------------------------------------------

# Subscription API

Create:

    /api/v1/subscriptions/

Endpoints:

    GET /plans/

    GET /my-subscription/

------------------------------------------------------------------------

# Flutter Integration

Create:

    mobile/lib/features/profile/

Structure:

    data/

    profile_api_service.dart

    profile_repository.dart


    models/

    profile_model.dart

    statistics_model.dart


    providers/

    profile_provider.dart


    screens/

    profile_screen.dart

    edit_profile_screen.dart

    verification_screen.dart

    subscription_screen.dart

------------------------------------------------------------------------

# Mobile Features

## Profile Screen

Replace mock data with API data.

Display:

-   Avatar
-   Username
-   Level
-   XP
-   Trust score
-   Verification badge
-   Subscription

------------------------------------------------------------------------

## Edit Profile

Allow:

-   Name update
-   Bio update
-   Country
-   Language
-   Currency
-   Preferences

------------------------------------------------------------------------

## Verification Screen

Display:

-   Current status
-   Requirements
-   Submission option

No real KYC processing.

------------------------------------------------------------------------

## Subscription Screen

Display:

-   Available plans
-   Benefits
-   Current plan

No payments.

------------------------------------------------------------------------

# Testing Requirements

Backend tests:

-   Profile retrieval
-   Profile update
-   Preferences update
-   Verification submission
-   Subscription listing

Flutter tests:

-   Profile provider
-   Profile rendering
-   Edit profile flow
-   Verification screen
-   Subscription screen

------------------------------------------------------------------------

# Completion Criteria

Phase 3 is complete when:

-   User profiles are fully connected.
-   User preferences work.
-   Statistics foundation exists.
-   Verification foundation exists.
-   Trust history exists.
-   Subscription foundation exists.
-   Flutter displays real user data.
-   Tests pass.

------------------------------------------------------------------------

# Restrictions

Do not build:

-   Wallet
-   Withdrawals
-   KYC provider integration
-   Payment gateway
-   Marketplace transactions
-   Reward calculations

Those belong to later phases.

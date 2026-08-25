# VEWRA Phase 2 Identity & Authentication Foundation Implementation Plan

## Phase Purpose

Phase 2 creates the identity foundation of VEWRA.

Phase 1 created the application shell, navigation, gamification
placeholders, and ecosystem UI foundation.

Phase 2 connects the first real system: user identity.

Everything in VEWRA depends on this phase.

Future systems require a reliable identity layer:

-   Wallet ownership
-   Rewards ownership
-   Verification
-   Trust score
-   Level progression
-   Marketplace permissions
-   Creator tools
-   Withdrawals
-   Fraud prevention
-   Subscriptions

This phase must create the foundation correctly before other backend
systems are added.

------------------------------------------------------------------------

# Development Approach

Follow the VEWRA vertical development method:

UI preparation ↓ Backend foundation ↓ Database models ↓ API endpoints ↓
Mobile integration ↓ Testing ↓ Documentation update

Do not build unrelated features.

------------------------------------------------------------------------

# Technology Requirements

## Mobile

Framework:

Flutter

Current architecture:

    mobile/lib/

    core/
    features/
    models/
    services/

Continue using:

-   Riverpod
-   Dio
-   Secure storage
-   Environment configuration

------------------------------------------------------------------------

## Backend

Create:

    backend/

Technology:

-   Python
-   Django
-   Django REST Framework

Database:

Local development:

MySQL

Production:

PostgreSQL

Important:

Use Django ORM.

Do not write database-specific SQL.

------------------------------------------------------------------------

# Backend Project Structure

Create:

    backend/

    manage.py

    config/

        settings/
            base.py
            development.py
            production.py

        urls.py
        asgi.py
        wsgi.py


    apps/

        users/
        authentication/
        security/


    requirements.txt
    .env.example

------------------------------------------------------------------------

# Database Foundation

Create the first database entities.

------------------------------------------------------------------------

# User Model

Do not use Django's default User model.

Create a custom user model.

Location:

    backend/apps/users/models.py

Example structure:

``` python
class User(AbstractBaseUser, PermissionsMixin):

    email
    username
    phone_number
    country
    currency
    timezone

    is_active
    is_verified

    created_at
    updated_at
```

The model must support future expansion.

------------------------------------------------------------------------

# User Profile Model

Location:

    backend/apps/users/models.py

Fields:

    user

    avatar

    level

    xp

    trust_score

    verification_status

    subscription_tier

    created_at
    updated_at

Purpose:

Stores user ecosystem information.

------------------------------------------------------------------------

# Verification Model

Location:

    backend/apps/security/models.py

Fields:

    user

    verification_level

    document_status

    verified_at

    reviewed_by

    created_at

Initial statuses:

    BASIC

    PENDING

    VERIFIED

    REJECTED

------------------------------------------------------------------------

# Device Security Model

Location:

    backend/apps/security/models.py

Prepare for future fraud prevention.

Fields:

    user

    device_id

    platform

    app_version

    is_trusted

    last_seen

    created_at

Do not implement full fraud engine yet.

Prepare the database.

------------------------------------------------------------------------

# Authentication Features

Implement:

## Registration

Users can register with:

-   Email
-   Password
-   Username
-   Country

Prepare phone verification support.

------------------------------------------------------------------------

## Login

Support:

-   Email login
-   Password authentication

Return:

-   Access token
-   Refresh token

Use JWT authentication.

------------------------------------------------------------------------

## Logout

Invalidate refresh tokens.

------------------------------------------------------------------------

## Password Reset

Create:

-   Request reset
-   Confirm reset

------------------------------------------------------------------------

## User Session

Mobile app should:

-   Save tokens securely
-   Restore sessions
-   Logout correctly

------------------------------------------------------------------------

# API Structure

Create:

    /api/v1/

Structure:

    api/v1/

    authentication/

        register/
        login/
        logout/
        refresh/
        password-reset/


    users/

        profile/
        update-profile/

------------------------------------------------------------------------

# Django Files

Create:

    backend/apps/authentication/

    views.py
    serializers.py
    urls.py
    services.py
    tests.py


    backend/apps/users/

    models.py
    serializers.py
    views.py
    urls.py
    services.py
    tests.py


    backend/apps/security/

    models.py
    services.py
    tests.py

------------------------------------------------------------------------

# Mobile Changes

Connect Flutter to real authentication.

Create:

    mobile/lib/features/auth/

    data/

        auth_repository.dart
        auth_api_service.dart

    providers/

        auth_provider.dart

    models/

        auth_response_model.dart

    screens/

        login_screen.dart
        register_screen.dart

------------------------------------------------------------------------

# API Service

Use Dio.

Create:

    mobile/lib/core/network/

    api_client.dart
    api_constants.dart

Responsibilities:

-   Base URL handling
-   Headers
-   Error handling
-   Token injection

------------------------------------------------------------------------

# Token Storage

Create:

    mobile/lib/core/storage/

    secure_storage_service.dart

Store:

-   Access token
-   Refresh token

Never store passwords.

------------------------------------------------------------------------

# Authentication State

Use Riverpod.

Create:

    mobile/lib/features/auth/providers/auth_provider.dart

States:

    authenticated

    unauthenticated

    loading

    error

------------------------------------------------------------------------

# UI Updates

Connect existing screens:

Login:

Before:

Mock login

After:

Real API authentication

Register:

Before:

UI only

After:

Create account through API

Profile:

Replace dummy user data with API data.

------------------------------------------------------------------------

# Security Requirements

Prepare for:

-   VPN checks
-   Root detection
-   Developer mode detection
-   App integrity verification

Do not implement full fraud protection yet.

Create extension points.

------------------------------------------------------------------------

# Testing Requirements

Backend:

Create tests for:

-   User registration
-   Login
-   Logout
-   Token refresh
-   Password reset
-   Profile retrieval

Flutter:

Create tests for:

-   Login state
-   Register flow
-   Token persistence
-   Authentication routing

------------------------------------------------------------------------

# Completion Criteria

Phase 2 is complete when:

-   Django backend runs.
-   Database migrations work.
-   User registration works.
-   Login works.
-   JWT authentication works.
-   Flutter connects to backend.
-   User sessions persist.
-   Existing Phase 1 UI remains working.
-   Tests pass.

------------------------------------------------------------------------

# Important Restrictions

Do not build:

-   Wallet logic
-   Payments
-   Marketplace transactions
-   Rewards calculations
-   Verification provider integration

Those belong to later phases.

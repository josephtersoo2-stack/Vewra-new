# VEWRA Master Implementation Plan (Fresh Project)

## Version

1.0

## Project Status

Greenfield Development

## Development Approach

UI-first, feature-driven, continuously integrated development.

------------------------------------------------------------------------

# 1. Project Vision

VEWRA is a cross-platform rewards platform where users complete verified
activities through a controlled mobile experience and earn rewards
managed by a secure backend system.

The project will be rebuilt from the ground up using a modular
architecture that supports future growth into memberships, referrals,
marketplaces, analytics, automation, and intelligent reward systems.

The development process will follow a strict vertical feature delivery
model:

1.  Design the user experience.
2.  Build the mobile interface.
3.  Create the backend capability required by that interface.
4.  Connect the backend function to the application.
5.  Test the complete user journey.
6.  Improve and document before moving to the next feature.

No backend feature should exist without a working application connection
unless it is an internal service required for future functionality.

------------------------------------------------------------------------

# 2. AI Agent Development Rules

This project will be developed with AI coding agents including Google
Antigravity and VS Code AI agents.

Every agent working on the project must follow these rules:

-   Understand existing architecture before modifying files.
-   Do not create duplicate systems.
-   Do not introduce unnecessary dependencies.
-   Keep features modular.
-   Write clean production-quality code.
-   Add tests with every major function.
-   Document architectural decisions.
-   Never hardcode secrets.
-   Never hardcode environment-specific values.
-   Use environment variables for configuration.
-   Keep production migration paths open.
-   Avoid database-specific implementations.

Business logic must remain separate from:

-   UI components
-   API controllers
-   database models
-   external services

------------------------------------------------------------------------

# 3. Technology Direction

## Mobile Application

Framework: - Flutter

Architecture: - Feature-based architecture

Recommended tools: - Riverpod or Bloc - Dio networking - Secure
storage - Local caching - flutter_inappwebview

## Backend

Framework: - Django - Django REST Framework

Services:

-   Authentication
-   User management
-   Task management
-   Tracking
-   Rewards
-   Wallet
-   Membership preparation
-   Referral preparation

## Database Strategy

Local Development:

-   MySQL will be used for local development and testing.

Production:

-   PostgreSQL will be used when deployed to VPS infrastructure.

Rules:

-   Use Django ORM.
-   Avoid raw SQL unless absolutely necessary.
-   Never use MySQL-only features.
-   Database design must remain PostgreSQL compatible.
-   Environment configuration must control database selection.

The application must be able to switch databases through configuration
without rewriting application logic.

------------------------------------------------------------------------

# 4. Repository Structure

Recommended structure:

    vewra/

    ├── backend/
    ├── mobile/
    ├── admin/
    ├── docs/
    ├── docker/
    ├── scripts/
    └── README.md

------------------------------------------------------------------------

# 5. Development Methodology

Development will happen through complete feature cycles.

Example:

## Feature: User Login

Step 1: Design login screens.

Step 2: Build Flutter UI.

Step 3: Create backend authentication API.

Step 4: Connect Flutter to API.

Step 5: Test login flow.

Step 6: Document completion.

Then move to the next feature.

------------------------------------------------------------------------

# 6. Phase 0: Foundation

Goal: Create a stable development environment.

Tasks:

-   Create repository structure.
-   Configure Flutter project.
-   Configure Django project.
-   Configure environment files.
-   Configure Docker development environment.
-   Configure database switching.
-   Configure code formatting.
-   Configure testing framework.

Deliverables:

-   Application launches.
-   Backend runs.
-   Database connects.
-   Mobile app communicates with backend.

------------------------------------------------------------------------

# 7. Phase 1: Application UI/UX Foundation

This phase starts before backend development.

Goal: Create the complete visual experience.

Screens:

## Authentication

-   Splash screen
-   Welcome screen
-   Login
-   Registration
-   Password recovery

## Main Application

-   Home dashboard
-   Task listing
-   Task details
-   Browser screen
-   Wallet screen
-   Profile screen
-   Settings screen

## UI System

Create:

-   Colour system
-   Typography
-   Components
-   Buttons
-   Cards
-   Navigation
-   Loading states
-   Error states
-   Empty states

The application should feel complete before backend wiring begins.

------------------------------------------------------------------------

# 8. Phase 2: Authentication Vertical Feature

Build complete authentication.

Mobile:

-   Login UI
-   Registration UI
-   Token storage
-   Session handling

Backend:

-   User model
-   Authentication APIs
-   JWT system

Integration:

-   Connect screens to APIs.
-   Test registration.
-   Test login.
-   Test logout.
-   Test expired sessions.

------------------------------------------------------------------------

# 9. Phase 3: User Profile System

Mobile:

-   Profile page
-   User information display
-   Settings interface

Backend:

-   Profile model
-   Profile APIs

Integration:

-   Load user data.
-   Update profile.
-   Test changes.

------------------------------------------------------------------------

# 10. Phase 4: YouTube Task System

Core VEWRA feature.

Backend:

VideoTask:

-   title
-   YouTube URL
-   video ID
-   keywords
-   thumbnail
-   reward rules
-   status

Mobile:

-   Task list
-   Task details
-   Search instructions
-   Start task flow

Integration:

User can:

-   View tasks.
-   Open task.
-   Receive instructions.
-   Start watching.

------------------------------------------------------------------------

# 11. Phase 5: In-App Browser and Tracking Engine

Mobile:

Technology:

-   flutter_inappwebview

Features:

-   YouTube browsing.
-   JavaScript injection.
-   Video detection.
-   Playback tracking.
-   Session recovery.

Backend:

WatchSession:

-   user
-   task
-   progress
-   completion status

Integration:

Test:

-   Correct video detection.
-   Wrong video rejection.
-   Resume watching.
-   Progress saving.

------------------------------------------------------------------------

# 12. Phase 6: Reward and Wallet System

Backend:

Wallet:

-   balance

WalletTransaction:

-   earning history
-   adjustments
-   references

Reward engine:

-   Per time rewards
-   Watch completion rewards
-   Target rewards

Mobile:

-   Wallet screen
-   Transaction history

Integration:

Complete:

Watch video → validate → reward → update wallet.

------------------------------------------------------------------------

# 13. Phase 7: Admin System

Initial:

Django Admin.

Features:

-   Manage users.
-   Manage videos.
-   View sessions.
-   View rewards.

Future:

Custom administration dashboard.

------------------------------------------------------------------------

# 14. Future Expansion Roadmap

## Phase 8

Membership:

-   Free plans
-   Paid plans
-   Feature restrictions
-   Subscription management

## Phase 9

Referral System:

-   Referral codes
-   Referral rewards
-   Anti-abuse controls

## Phase 10

Gamification:

-   Daily tasks
-   Streaks
-   Achievements
-   Leaderboards

## Phase 11

Marketplace:

-   Spending coins
-   Products
-   Redeeming rewards

## Phase 12

Advanced Intelligence:

-   Recommendation engine
-   Fraud detection
-   Automated analytics
-   AI-assisted operations

------------------------------------------------------------------------

# 15. Testing Strategy

Every feature requires:

## Backend

-   Unit tests
-   API tests
-   Security tests

## Mobile

-   Widget tests
-   Integration tests

## Feature Acceptance

A feature is complete only when:

-   UI works.
-   Backend works.
-   Integration works.
-   Tests pass.
-   Documentation exists.

------------------------------------------------------------------------

# 16. Security Requirements

Mandatory:

-   JWT authentication.
-   Secure storage.
-   Input validation.
-   Rate limiting.
-   Server-side reward validation.
-   Transaction auditing.
-   Environment-based configuration.

The client must never control rewards.

------------------------------------------------------------------------

# 17. Deployment Preparation

Prepare for VPS deployment:

-   PostgreSQL migration.
-   Docker production setup.
-   Environment management.
-   Database backups.
-   Logging.
-   Monitoring.
-   CI/CD pipeline.

------------------------------------------------------------------------

# 18. Final Development Principle

VEWRA will be built as a connected product.

Every screen must eventually connect to real backend functionality.

Every backend capability must have a user-facing purpose.

Every completed feature must be tested before starting the next feature.

The goal is not only to create working software, but to create a
maintainable platform that can grow into a large-scale product.

# VEWRA PHASE 5.5 STEP 3 IMPLEMENTATION PLAN

# CAMPAIGN ADVERTISEMENT DELIVERY FOUNDATION

## Objective

Build the foundation that allows approved campaign media assets to be
displayed across VEWRA application surfaces.

This step does not implement advertising monetisation, billing, auction
systems, advanced targeting, or complete analytics.

This step creates the controlled advertisement delivery layer required
for future expansion.

------------------------------------------------------------------------

## Development Rules

VEWRA is a production application.

Do not create prototypes.

Every feature must include:

-   database structure
-   backend logic
-   API endpoints
-   permissions
-   admin controls
-   mobile integration where required
-   automated tests

Do not guess future features. Create extension points only where
required.

------------------------------------------------------------------------

# STEP 3 SCOPE

Create advertisement placement management.

Supported placement locations:

-   Home feed
-   Header banner
-   Footer banner
-   Popup advertisement
-   Video pre-roll foundation
-   Task feed advertisement section

Do not implement billing, impressions, clicks, payments, or advanced
targeting in this step.

------------------------------------------------------------------------

# Backend Implementation

Location:

backend/apps/campaigns/

Create:

-   advertisement placement models
-   delivery services
-   serializers
-   selectors
-   views
-   URLs
-   permissions
-   tests

Create:

CampaignAdPlacement model.

Fields:

-   id (UUID)
-   campaign
-   media
-   placement_type
-   status
-   priority
-   start_date
-   end_date
-   created_by
-   created_at
-   updated_at

Placement types:

-   HOME_FEED
-   HEADER
-   FOOTER
-   POPUP
-   VIDEO_PREROLL
-   TASK_FEED

Status:

-   DRAFT
-   ACTIVE
-   PAUSED
-   DISABLED

------------------------------------------------------------------------

# Database Rules

Create migrations.

Add indexes:

-   placement_type
-   status
-   campaign
-   media

Rules:

-   Disabled campaign cannot deliver advertisements.
-   Disabled media cannot appear.
-   Only READY campaign media can be attached.

------------------------------------------------------------------------

# Service Layer

Create:

CampaignAdDeliveryService

Required functions:

-   create_placement()
-   activate_placement()
-   pause_placement()
-   disable_placement()
-   get_active_ads_by_location()

Keep business rules inside services.

------------------------------------------------------------------------

# API Requirements

Create:

GET /api/v1/ads/{placement_type}/

Returns active advertisements for clients.

POST /api/v1/campaigns/{id}/placements/

Creates placement.

PATCH /api/v1/ad-placement/{id}/

Updates placement.

DELETE /api/v1/ad-placement/{id}/

Disables placement.

------------------------------------------------------------------------

# Security

Normal users:

-   receive approved advertisements only
-   cannot manage advertisements

Advertisers:

-   manage only their own campaign placements

Admins:

-   full access

Validate:

-   campaign ownership
-   media ownership
-   campaign status
-   media status

------------------------------------------------------------------------

# Admin Dashboard

Add:

Campaign Management

-   Campaign Overview
-   Campaign List
-   Campaign Media
-   Advertisement Placements
-   Pending Review
-   Disabled

Admin functions:

-   assign media
-   activate placement
-   pause placement
-   disable placement
-   filter placements

------------------------------------------------------------------------

# Flutter Implementation

Create:

mobile/lib/features/advertising/

Files:

models/ad_placement_model.dart

data/ad_api_service.dart

data/ad_repository.dart

providers/ad_provider.dart

widgets/advertisement_card.dart

screens/advertisement_preview_screen.dart

Requirements:

-   API integration
-   loading states
-   empty states
-   error states

Do not implement payment tracking or click analytics.

------------------------------------------------------------------------

# Testing

Backend:

-   placement creation
-   permission checks
-   advertiser isolation
-   disabled media rejection
-   expired placement rejection
-   API tests

Flutter:

-   model tests
-   provider tests
-   visibility tests

Admin:

npm run build

------------------------------------------------------------------------

# Completion Requirement

Do not close Step 3 until:

Backend: - migrations pass - APIs work - permissions work - tests pass

Mobile: - advertisement display foundation works - tests pass

Admin: - placement management works

------------------------------------------------------------------------

# Git

Commit:

feat: implement campaign advertisement delivery foundation

Push to:

origin main

------------------------------------------------------------------------

# Final Report

Include:

1.  Files created.
2.  Files modified.
3.  Database changes.
4.  API endpoints.
5.  Security implementation.
6.  Admin implementation.
7.  Mobile implementation.
8.  Tests executed.
9.  Git commit hash.
10. Deferred dependencies.

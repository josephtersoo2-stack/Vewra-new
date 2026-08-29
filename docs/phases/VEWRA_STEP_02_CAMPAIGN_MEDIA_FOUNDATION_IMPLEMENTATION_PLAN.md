# VEWRA STEP 2 IMPLEMENTATION PLAN

# CAMPAIGN MEDIA FOUNDATION (VIDEO AND BANNER ASSETS)

## Objective

Build the secure media foundation under the existing Campaign module.

This step creates the system that allows authorised administrators and
verified advertisers to upload, manage, validate and attach campaign
media.

This step does not implement the full advertisement serving engine.
Features such as ad placement, impressions, clicks, billing, analytics
and feed delivery remain future steps.

The AI agent must complete backend, admin, mobile integration, testing
and documentation before moving forward.

------------------------------------------------------------------------

# AI AGENT DEVELOPMENT RULES

Do not create prototypes or incomplete placeholders.

Every feature must include: - database changes - migrations - backend
services - API endpoints - permissions - admin interface - mobile
integration where required - automated tests

Do not guess future functionality.

------------------------------------------------------------------------

# STEP 2.1 DATABASE IMPLEMENTATION

Location:

backend/apps/campaigns/

Create:

CampaignMedia model.

Fields:

-   id (UUID primary key)
-   campaign (ForeignKey Campaign)
-   media_type (VIDEO, IMAGE, BANNER)
-   file
-   thumbnail
-   title
-   description
-   file_size
-   mime_type
-   duration_seconds
-   width
-   height
-   status (DRAFT, PROCESSING, READY, FAILED, DISABLED)
-   uploaded_by
-   created_at
-   updated_at

------------------------------------------------------------------------

# SECURITY REQUIREMENTS

Media uploads must:

-   require authentication
-   verify advertiser/admin permission
-   verify campaign ownership
-   validate extension
-   validate MIME type
-   limit file size
-   prevent unsafe uploads
-   generate safe filenames

Never trust client supplied file metadata.

------------------------------------------------------------------------

# STEP 2.2 MEDIA SERVICE

Create:

backend/apps/campaigns/media_services.py

Create MediaValidationService.

Responsibilities:

-   validate uploaded images
-   validate uploaded videos
-   extract metadata
-   create thumbnails where possible
-   return validation errors

Supported formats:

Images: jpg, jpeg, png, webp

Videos: mp4, mov

Limits:

Images: 10MB Videos: 500MB

------------------------------------------------------------------------

# STEP 2.3 API IMPLEMENTATION

Create:

GET: /api/v1/campaigns/{id}/media/

POST: /api/v1/campaigns/{id}/media/upload/

PATCH: /api/v1/campaign-media/{id}/

DELETE: /api/v1/campaign-media/{id}/

Rules:

Only advertiser owners and admins can manage media.

Normal users cannot upload or manage campaign media.

------------------------------------------------------------------------

# STEP 2.4 ADMIN IMPLEMENTATION

Add Campaign Media management.

Admin options:

-   view media
-   filter by type
-   filter by status
-   preview media information
-   disable media
-   restore media
-   view uploader
-   view upload date

------------------------------------------------------------------------

# STEP 2.5 ADVERTISER ACCESS CONTROL

Advertisers can only manage their own campaign media.

Advertiser A must not access Advertiser B media.

Admins have full access.

------------------------------------------------------------------------

# STEP 2.6 FLUTTER IMPLEMENTATION

Location:

mobile/lib/features/campaigns/

Create:

models/campaign_media_model.dart

services/campaign_media_api_service.dart

providers/campaign_media_provider.dart

screens/campaign_media_screen.dart

widgets/campaign_media_card.dart

Requirements:

-   API connection
-   loading states
-   empty states
-   errors
-   validation
-   tests

Normal users must not see upload controls.

------------------------------------------------------------------------

# STEP 2.7 REQUIRED MENU ITEMS

Admin:

Campaigns

-   Campaign Overview
-   Campaign List
-   Campaign Media
-   Pending Media Review
-   Disabled Media

Advertiser:

Campaigns

-   My Campaigns
-   Campaign Media
-   Upload Media

Mobile user navigation:

Do not expose advertiser management menus.

------------------------------------------------------------------------

# STEP 2.8 TEST REQUIREMENTS

Backend tests:

-   media creation
-   invalid upload rejection
-   permissions
-   ownership protection
-   API upload
-   update
-   disable/delete

Flutter tests:

-   model parsing
-   provider behaviour
-   upload validation
-   permission visibility

------------------------------------------------------------------------

# STEP 2.9 COMPLETION REQUIREMENT

Step 2 is complete only when:

Backend: - migrations pass - APIs work - permissions work - tests pass

Mobile: - screens work - API connects - tests pass

Admin: - management interface works

Commit:

feat: implement campaign media foundation

Push to main branch before starting Step 3.

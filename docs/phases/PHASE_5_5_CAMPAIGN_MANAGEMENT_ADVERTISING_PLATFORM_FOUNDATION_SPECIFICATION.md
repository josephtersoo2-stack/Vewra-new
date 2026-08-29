# PHASE 5.5: CAMPAIGN MANAGEMENT & ADVERTISING PLATFORM FOUNDATION IMPLEMENTATION SPECIFICATION

## Purpose

This phase creates the central Campaign ecosystem for VEWRA.

The Campaign system is the parent system that connects:

- User earning campaigns
- Advertiser campaigns
- Banner advertisements
- Video advertisements
- Sponsored content
- Advertisement placements
- Analytics
- Future billing systems

The implementation must be completed step by step. Do not build the entire phase at once.

Each step must be completed, tested, reviewed, and verified before moving to the next step.

---

# Global Development Rules

Before coding:

Read and follow:

- VEWRA_MASTER_IMPLEMENTATION_PLAN.md
- ARCHITECTURE_DECISIONS.md
- Previous phase completion reviews

Do not redesign existing architecture.

Reuse existing systems:

- Authentication system
- UserService
- WalletService
- Phase 5 Task Tracking Engine
- Existing API client
- Existing Flutter architecture

Do not create duplicate services.

Every feature must connect:

Database
↓
Backend Service
↓
API
↓
Mobile/Admin Interface
↓
Tests

Do not create fake functionality or placeholder systems.

If a feature depends on a future phase, create only the correct integration point and document the dependency.

---

# Required Menu Structure

## Admin Dashboard

Campaign Management

- All Campaigns
- Create Campaign
- Pending Approval
- Active Campaigns
- Paused Campaigns
- Completed Campaigns
- Rejected Campaigns

Task Campaigns

- Video Tasks
- Survey Tasks
- Social Tasks
- Challenges

Advertisement Campaigns

- Banner Ads
- Video Ads
- Feed Ads
- Popup Ads
- Pre-roll Ads
- Sponsored Content

---

## Advertiser Dashboard

Campaigns

- Dashboard
- Create Campaign
- My Campaigns
- Drafts
- Active Campaigns
- Paused Campaigns
- Completed Campaigns

Advertisement

- Creatives
- Audience Targeting
- Budget Management
- Analytics

---

## Mobile Application

Earn

- Available Tasks
- Videos
- Surveys
- Challenges

Home

- Sponsored Content
- Feed Advertisements
- Recommended Campaigns

---

# STEP 1: Campaign Core Foundation

## Purpose

Create the central campaign engine that all future campaign types will use.

Architecture:

Campaign

|

|---- Task Campaign

|

|---- Advertisement Campaign

|

|---- Sponsored Content

Do not create separate unrelated campaign systems.

---

# Backend Implementation

## Create Django App

Location:

backend/apps/campaigns/

Required files:

campaigns/

- apps.py
- models.py
- serializers.py
- services.py
- selectors.py
- views.py
- urls.py
- admin.py
- permissions.py

tests/

- test_models.py
- test_services.py
- test_api.py

---

# Database Design

## Campaign Model

Location:

backend/apps/campaigns/models.py


Create:

Campaign


Fields:

id

UUID primary key


owner

ForeignKey(User)


campaign_type

Options:

- TASK
- ADVERTISEMENT
- SPONSORED_CONTENT


title

CharField(max_length=255)


description

TextField


status

Options:

- DRAFT
- PENDING_REVIEW
- ACTIVE
- PAUSED
- COMPLETED
- REJECTED


budget

DecimalField


start_date


end_date


created_at


updated_at


---

# Database Requirements

Add indexes:

- status
- campaign_type
- owner


Example:

class Meta:

    indexes = [
        models.Index(fields=["status"]),
        models.Index(fields=["campaign_type"]),
    ]


Reason:

Campaign data will grow significantly.

---

# Security Implementation

Create:

permissions.py


Implement:

## IsCampaignOwner

Rules:

Advertiser can:

- Create campaigns
- Edit own draft campaigns

Advertiser cannot:

- Approve campaigns
- Activate campaigns
- Change approved budgets


## IsAdminCampaignManager

Admin can:

- View all campaigns
- Approve campaigns
- Reject campaigns
- Pause campaigns

---

# API Implementation

Location:

urls.py


Base:

/api/v1/campaigns/


## Create Campaign

POST

/campaigns/create/


Request:

{
"title":"Samsung Product Promotion",
"type":"ADVERTISEMENT",
"description":"Product campaign"
}


Response:

{
"id":"uuid",
"status":"DRAFT"
}


---

## List Campaigns

GET

/campaigns/


Filters:

?status=ACTIVE

?type=ADVERTISEMENT


---

## Campaign Detail

GET

/campaigns/<uuid>/


---

# Service Layer

Location:

services.py


Create:

CampaignService


Methods:

create_campaign()

submit_for_review()

approve_campaign()

reject_campaign()

pause_campaign()


Business Rules:

A campaign cannot become ACTIVE unless:

- Status is PENDING_REVIEW
- Admin approval exists

---

# Testing Requirements

Run:

python manage.py test apps.campaigns


Must verify:

- Campaign creation
- Permissions
- Status transitions
- API responses
- Database constraints

---

# Flutter Implementation

Create:

mobile/lib/features/campaigns/


Structure:

models/

campaign_model.dart


data/

campaign_api_service.dart

campaign_repository.dart


providers/

campaign_provider.dart


screens/

campaign_list_screen.dart

campaign_detail_screen.dart


widgets/

campaign_card.dart


---

# Flutter Model

File:

campaign_model.dart


Must match backend fields:

- id
- title
- type
- status
- budget


---

# API Connection

File:

campaign_api_service.dart


Use existing:

ApiClient


Do not create another HTTP client.


Connect:

GET /campaigns/

POST /campaigns/create/

---

# UI Requirements

Add:

Admin:

Campaign Management


Advertiser:

My Campaigns


Mobile:

Earn > Campaigns


---

# Step Completion Requirement

STEP 1 is complete only when:

Backend:

- Models created
- Migration applied
- APIs working
- Permissions working
- Tests passed


Flutter:

- Screens created
- API connected
- Provider connected
- Tests passed


Repository:

- GitHub reviewed
- Implementation matches this specification

---

# Future Steps

The remaining implementation steps will follow the same structure:

STEP 2:
Campaign Approval Workflow

STEP 3:
Video Campaign System

STEP 4:
Banner Advertisement System

STEP 5:
Video Advertisement System

STEP 6:
Advertisement Placement Engine

STEP 7:
Audience Targeting

STEP 8:
Advertisement Tracking

STEP 9:
Billing Foundation

STEP 10:
Mobile Advertisement Display System

STEP 11:
Complete Integration Testing

Each step must include:

- Files
- Database schema
- API design
- Security rules
- Business logic
- Mobile implementation
- Tests
- Verification requirements

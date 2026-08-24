# VEWRA Phase 1 Implementation Plan

## Phase Name
Application UI/UX Foundation

## Objective
Create the complete VEWRA mobile application template before backend integration.

This phase establishes the visual system, navigation, reusable components, feature folders, screen layouts, local placeholder models, and UI states that later backend services will connect to.

The development rule is:

Template first → Build functionality → Connect backend → Update template → Test.

---

# AI Agent Mission

You are implementing VEWRA Phase 1.

Your goal is to create a complete Flutter application foundation.

Do not build backend functionality in this phase.

Do not create API endpoints.

Do not create temporary shortcuts that prevent future integration.

Create a clean product template that later phases will activate.

---

# Development Order

1. Inspect Flutter project.
2. Create feature-based architecture.
3. Create design system.
4. Create reusable components.
5. Create navigation.
6. Build all screens.
7. Add local dummy models.
8. Add widget tests.
9. Verify complete navigation.

---

# Mobile Structure

```
mobile/lib/

core/
 ├── theme/
 ├── constants/
 ├── routing/
 ├── widgets/
 └── utils/

features/
 ├── splash/
 ├── auth/
 ├── home/
 ├── tasks/
 ├── browser/
 ├── wallet/
 ├── profile/
 └── settings/

models/
services/
main.dart
```

---

# Design System

Create:

- Colours
- Typography
- Buttons
- Cards
- Inputs
- Loading states
- Empty states
- Error states

All styling must remain centralised.

Do not place repeated styling inside widgets.

---

# Required Screens

## Splash

Purpose:

Application entry point.

Contains:

- VEWRA branding
- Loading state
- Future authentication check location


## Welcome

Contains:

- Introduction
- Login button
- Register button


## Login

Components:

- Email field
- Password field
- Login button
- Forgot password link


## Register

Components:

- Username
- Email
- Password
- Confirm password
- Register button


## Home Dashboard

Contains:

- User greeting
- Wallet placeholder
- Task preview
- Navigation


## Tasks

Contains:

- Task cards
- Thumbnail placeholder
- Reward display
- Start button

Local model:

```
TaskModel

id
title
thumbnail
rewardAmount
duration
```


## Task Details

Contains:

- Thumbnail
- Description
- Reward information
- Instruction placeholder
- Start button


## Browser

Create the future WebView location.

Only create the UI.

Do not implement tracking.


## Wallet

Contains:

- Balance card
- Transaction list placeholder


## Profile

Contains:

- Avatar
- Username
- Email
- Edit button


## Settings

Contains:

- Account settings
- Theme placeholder
- Logout placeholder

---

# Navigation

Create routes:

```
/splash
/login
/register
/home
/tasks
/task-details
/browser
/wallet
/profile
/settings
```

Prepare navigation for authentication guards later.

---

# Local Models

Create:

```
UserModel
TaskModel
WalletModel
TransactionModel
```

These models will later map to backend responses.

---

# Rules For AI Agent

Do:

- Keep features separated.
- Create reusable widgets.
- Separate UI from logic.
- Prepare future API integration.

Do not:

- Put API calls inside widgets.
- Hardcode colours everywhere.
- Duplicate components.
- Add unnecessary dependencies.
- Create backend code.

---

# Testing

Create:

## Widget Tests

Verify:

- Screens render.
- Components display.
- Buttons work.

## Navigation Tests

Verify:

- Login flow.
- Registration flow.
- Dashboard navigation.
- Task navigation.
- Wallet navigation.

---

# Completion Checklist

## Foundation

[x] Flutter structure completed

[x] Theme created

[x] Navigation completed

[x] Components created


## Screens

[x] Splash

[x] Welcome

[x] Login

[x] Register

[x] Home

[x] Tasks

[x] Task Details

[x] Browser

[x] Wallet

[x] Profile

[x] Settings


## Quality

[x] Tests passing

[x] UI reviewed

[x] Documentation updated

---

# AI Implementation Prompt

You are implementing VEWRA Phase 1: Application UI/UX Foundation.

Read this document before modifying files.

Create the Flutter application template first.

Follow this order:

1. Inspect the current Flutter project.
2. Create the feature architecture.
3. Create the design system.
4. Create reusable components.
5. Create navigation.
6. Build every required screen.
7. Add placeholder models.
8. Add tests.
9. Verify the application flow.

Important:

- Do not create backend functionality.
- Do not create API endpoints.
- Do not put logic inside widgets.
- Do not hardcode styles.
- Keep all code ready for future backend connection.

When complete report:

1. Created files.
2. Modified files.
3. Tests completed.
4. Problems found.
5. Recommendations before Phase 2.

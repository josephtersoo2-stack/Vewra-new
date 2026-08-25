# VEWRA Phase 1 UI/UX Foundation Retrofit Implementation Plan

## Purpose

This phase upgrades the existing VEWRA Flutter application template to support the expanded VEWRA ecosystem vision.

Phase 1 already created the application shell. This retrofit prepares the UI foundation for future systems without adding backend functionality.

Development rule:

Template first → Build functionality → Connect backend → Test → Expand.

## Objective

Review and improve the existing app foundation for:

- Rewards ecosystem
- User levels and XP
- Verification
- Trust score
- Marketplace
- Community
- Competitions
- Creator economy preparation

## Existing Features To Preserve

Do not remove:

- Splash
- Welcome
- Login
- Register
- Forgot Password
- Home
- Tasks
- Task Details
- Browser placeholder
- Wallet
- Profile
- Settings

Keep the existing feature architecture and reusable components.

## Navigation Preparation

Prepare navigation for future expansion.

Target structure:

Home
Earn
Rewards
Wallet
Profile

Future sections:

Earn:
- Video Tasks
- Surveys
- Social Tasks
- Challenges

Rewards:
- Daily Rewards
- Leaderboards
- Achievements
- Competitions

Profile:
- Level
- Verification
- Trust Score
- Subscription

## New UI Templates

Create placeholder screens only.

### Rewards Screen

Include:

- Level
- XP progress
- Daily rewards
- Leaderboard preview
- Achievement preview

### Marketplace Screen

Include:

- Airtime
- Data
- Gift cards
- Digital products
- Coin marketplace preview

### Community Screen

Include:

- Feed preview
- Groups preview
- Posts preview

### Verification Screen

Include:

- Verification status
- Requirements
- Upgrade button

## Dashboard Improvements

Prepare the home screen for:

- User progress card
- Level display
- XP display
- Trust score placeholder
- Verification badge placeholder
- Daily mission card
- Competition ranking card

## Wallet Improvements

Prepare layouts for:

- Coin balance
- Cash balance
- Pending rewards
- Withdraw
- Buy coins
- Sell coins

No payment functionality.

## Reusable Components

Create reusable widgets where required:

- RewardCard
- LevelProgressCard
- LeaderboardCard
- MarketplaceCard
- VerificationCard
- CommunityCard

## Rules

Do not add:

- APIs
- Backend logic
- Payment processing
- Reward calculations
- Authentication logic

Screens remain presentation only.

## Testing

Run:

flutter analyze

flutter test

Add tests for:

- New screens
- Routes
- Components
- Navigation

## Completion Criteria

Phase 1 Retrofit is complete when:

- Existing UI still works.
- New ecosystem templates exist.
- Navigation supports future modules.
- Components are reusable.
- Tests pass.

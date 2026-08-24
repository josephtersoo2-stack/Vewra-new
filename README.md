# VEWRA — Verified Content Rewards Platform

VEWRA is a cross-platform rewards platform where users complete verified activities through a controlled mobile experience and earn rewards managed by a secure backend system.

---

## Repository Structure

```
vewra/
├── mobile/      # Flutter mobile application (iOS, Android, Web, Desktop)
├── doc/         # Master implementation plan & phase specifications
├── backend/     # Django / DRF backend services (Upcoming in Phase 2)
└── README.md
```

---

## Phase 1: Application UI/UX Foundation (Completed)

- **Design System & Centralized Theme**: Modern dark aesthetic with Material 3 styling tokens.
- **Reusable Widget System**: Buttons, inputs, surface cards, metrics, feedback loaders/states, navigation.
- **Feature Screen Suite**:
  - Splash (`/splash`)
  - Welcome (`/welcome`)
  - Login (`/login`)
  - Register (`/register`)
  - Forgot Password (`/forgot-password`)
  - Home Dashboard (`/home`)
  - Tasks Listing & Filtering (`/tasks`)
  - Task Details & Instructions (`/task-details`)
  - In-App Viewer & Tracking HUD (`/browser`)
  - Wallet & Withdrawals (`/wallet`)
  - User Profile (`/profile`)
  - Settings & Preferences (`/settings`)
- **Automated Testing Suite**: 30/30 unit, widget, and navigation tests passing with 0 lint issues.

---

## Running the Mobile App

```bash
cd mobile
flutter pub get
flutter run
```

### Running Tests

```bash
cd mobile
flutter test
```

### Running Analysis

```bash
cd mobile
flutter analyze
```

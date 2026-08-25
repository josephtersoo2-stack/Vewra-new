# VEWRA Architecture Decision Records (ADRs)

This document captures the foundational architectural and technical stack decisions for the **VEWRA** mobile client ecosystem after Phase 1 completion, ensuring consistency across all future development phases.

---

## 1. Core Framework: Flutter

### Decision
Use **Flutter (Dart 3.x)** as the primary cross-platform mobile application framework.

### Why It Was Selected
- **Cross-Platform Consistency**: Single codebase deploying to iOS and Android with unified rendering performance (60/120fps).
- **Rich UI & Custom Canvas**: High-fidelity control over design tokens, animations, custom overlays, and tracking HUD elements required for the in-app viewing experience.
- **Strong Typing & Predictability**: Dart's sound null-safety and structured object-oriented paradigms provide compile-time safety across complex model hierarchies (tasks, transactions, wallets, users).
- **Rich Ecosystem**: Mature ecosystem supporting background services, WebViews, secure storage, and hardware integration.

### Where It Will Be Used
- The entire frontend client (`mobile/` directory).
- Reusable UI component system (`mobile/lib/core/widgets/`).
- Feature screens (`mobile/lib/features/`).

### Dependent Future Phases
- **All Phases (Phases 1 through 12)**: Forms the core frontend application layer.

---

## 2. State Management: `flutter_riverpod`

### Decision
Adopt **Riverpod (`flutter_riverpod: ^2.6.1`)** as the primary state management framework and dependency injection system.

### Why It Was Selected
- **Compile-Safe Dependency Injection**: Providers are declared globally without relying on `BuildContext` lookup trees, eliminating `ProviderNotFoundException` risks.
- **Fine-Grained Reactivity**: Supports `select()` and `watch()` for selective widget rebuilding, preventing unnecessary repaints during high-frequency events (e.g., live tracking timers).
- **Testability**: Independent unit testing of state notifiers and providers using container overrides without needing UI pump cycles for every business logic test.
- **Lifecycle & Cache Management**: Built-in auto-dispose and family modifiers simplify caching and lifecycle cleanup for task lists, user sessions, and transaction ledgers.

### Where It Will Be Used
- **Auth State**: Managing authenticated user sessions, JWT token lifecycles, and login/registration flows (`mobile/lib/features/auth/`).
- **Wallet & Balance State**: Synchronizing user coin balances, transaction histories, and withdrawal status (`mobile/lib/features/wallet/`).
- **Task Feeds & Filters**: Managing active task listings, category filters, and search queries (`mobile/lib/features/tasks/`).
- **Tracking Engine State**: Holding live seconds ticker, session tokens, and playback status (`mobile/lib/features/browser/`).

### Dependent Future Phases
- **Phase 2 (Authentication)**: `authProvider`, token lifecycle management, and auth guard navigation.
- **Phase 3 (User Profile)**: `userProfileProvider` for managing user metadata and preferences.
- **Phase 4 (Tasks)**: `taskFilterProvider` and `taskDetailsProvider`.
- **Phase 5 (Browser & Tracking Engine)**: `trackingSessionProvider` for real-time video validation and progress timers.
- **Phase 6 (Wallet & Rewards)**: `walletBalanceProvider` and `transactionLedgerProvider`.
- **Phases 8–10 (Memberships, Referrals, Gamification)**: Real-time user stats, tier states, and streak counters.

---

## 3. Networking: `dio`

### Decision
Use **Dio (`dio: ^5.7.0`)** as the centralized HTTP client.

### Why It Was Selected
- **Interceptors Support**: Enables automated token injection (Authorization header: `Bearer <token>`), request retries, centralized error parsing, and automated refresh-token interceptors on HTTP `401 Unauthorized`.
- **Global Configuration**: Centralized base URL, global timeout limits (connection, receive, send), and header definitions in a single networking service.
- **Transformers & Logging**: Clean JSON serialization handling and structured debug logging in non-production builds.
- **FormData & Cancellation**: Built-in cancellation tokens and multipart upload support for future avatar uploads.

### Where It Will Be Used
- Centralized API Client (`mobile/lib/core/network/api_client.dart` or `services/api_service.dart`).
- Feature-specific repository and service classes (`auth_service.dart`, `task_service.dart`, `wallet_service.dart`).

### Dependent Future Phases
- **Phase 2 (Authentication)**: Register, login, refresh JWT, logout endpoints.
- **Phase 3 (Profile)**: Fetch and update user profile, avatar upload.
- **Phase 4 (Task System)**: Fetching video task listings, task instructions, and eligibility.
- **Phase 5 (Tracking & Watch Sessions)**: Watch session initiation, heartbeat pings, and completion verification.
- **Phase 6 (Wallet & Transactions)**: Wallet balance queries, transaction logs, withdrawal requests.

---

## 4. Secure Storage: `flutter_secure_storage`

### Decision
Use **Flutter Secure Storage (`flutter_secure_storage: ^9.2.2`)** for storing sensitive client credentials.

### Why It Was Selected
- **Hardware-Backed Encryption**: Utilizes Keychain on iOS and Android Keystore AES encryption (with EncryptedSharedPreferences on Android), preventing credential extraction on rooted or compromised devices.
- **Isolation**: Keeps sensitive tokens strictly separated from regular plain-text storage.
- **Async API**: Simple, non-blocking CRUD operations for token strings.

### Where It Will Be Used
- `mobile/lib/services/token_storage_service.dart` or `core/storage/secure_storage.dart`.
- Storing JWT `accessToken`, `refreshToken`, and sensitive session identifiers.

### Dependent Future Phases
- **Phase 2 (Authentication)**: Persisting JWT tokens across app restarts; silent authentication on app launch.
- **Phase 5 (Browser & Tracking Engine)**: Storing ephemeral watch session security tokens.
- **Phase 6 (Wallet & Rewards)**: Securing transaction verification signatures where applicable.

---

## 5. Persistent Preferences: `shared_preferences`

### Decision
Use **Shared Preferences (`shared_preferences: ^2.3.3`)** for storing non-sensitive user preferences and client flags.

### Why It Was Selected
- **Lightweight Key-Value Store**: Fast, persistent storage for simple primitives (boolean flags, strings, integers) without encryption overhead.
- **Reliable Startup Access**: Ideal for reading display mode and onboarding flags during app startup before network connection is established.

### Where It Will Be Used
- `mobile/lib/features/settings/` and `core/storage/preferences_service.dart`.
- Preferences: App theme mode (Dark/Light), audio feedback toggles, push notification preferences, and onboarding/welcome completion flags.

### Dependent Future Phases
- **Phase 1 (UI Polish & Persistence)**: Retaining user UI settings (dark mode, notification toggles).
- **Phase 2 (Auth)**: Storing `hasSeenWelcome` or `rememberUsername` flags.
- **Phase 3 (Profile & Settings)**: Managing locale and application configuration options.

---

## 6. Environment Configuration: `flutter_dotenv`

### Decision
Use **Flutter Dotenv (`flutter_dotenv: ^5.2.1`)** for managing environment-specific configurations.

### Why It Was Selected
- **Decoupling Secrets & Endpoints**: Prevents hardcoding backend server URLs, API versions, or environment keys into Dart source code.
- **Multi-Environment Support**: Facilitates simple switching between local development (`http://10.0.2.2:8000/api` or `http://localhost:8000/api`), staging servers, and production VPS endpoints (`https://api.vewra.com/api`).
- **Security Best Practice**: `.env` files can be excluded from public source control while `.env.example` provides template schema definitions.

### Where It Will Be Used
- Loaded during `main()` initialization before widget launch.
- Referenced in `ApiClient` for `BASE_URL`, `API_TIMEOUT`, and environment indicators.

### Dependent Future Phases
- **Phase 2 (Authentication)**: Dynamically points auth endpoints to local or staging backend.
- **Phase 5 & 6 (Tracking & Wallet)**: Controlling environment-specific tracking URLs, validation rules, and webhook endpoints.
- **Phase 17 (VPS & Production Deployment)**: Seamless production endpoint switches.

---

## Summary Matrix

| Tool / Package | Category | Primary Purpose | Primary Dependent Phases |
| :--- | :--- | :--- | :--- |
| **Flutter** | Core Framework | Cross-platform mobile client application | All Phases (1–12) |
| **`flutter_riverpod`** | State Management | Reactive UI updates & dependency injection | Phases 2, 3, 4, 5, 6 |
| **`dio`** | Networking | REST API communication with interceptors | Phases 2, 3, 4, 5, 6 |
| **`flutter_secure_storage`** | Secure Storage | Hardware-encrypted JWT token persistence | Phase 2, 5 |
| **`shared_preferences`** | Key-Value Store | App settings, theme flags, onboarding states | Phase 1, 3 |
| **`flutter_dotenv`** | Configuration | Environment-based URL & API key management | Phases 2–17 |

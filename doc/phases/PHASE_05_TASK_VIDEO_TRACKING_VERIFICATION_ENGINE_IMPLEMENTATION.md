# VEWRA Phase 5 — Task, Video Tracking, Verification & Reward Engine Implementation Plan

## 1. Phase Purpose

Phase 5 converts the existing VEWRA Earn/Tasks and Browser placeholder UI into a real, server-authoritative earning engine. The current Flutter task feed still reads mock tasks and the current browser screen simulates watch progress and local reward completion. Phase 5 must replace those behaviours with PostgreSQL-backed task records, authenticated task attempts, watch sessions, server-processed heartbeats, completion verification, quiz checks, and idempotent wallet reward credits.

The backend is the final authority for task availability, eligibility, valid watch time, completion, quiz outcome, reward amount and reward settlement. Flutter must never credit coins or declare a task complete on its own.

Implementation sequence:

```text
Existing UI template
→ database models
→ backend services/selectors
→ authenticated REST APIs
→ Flutter repositories/providers
→ live task feed
→ live tracking/player flow
→ quiz flow
→ WalletService reward credit
→ automated tests
→ physical-device integration test
→ completion documentation
```

## 2. Architecture Synchronisation Before Coding

Update these documents before feature implementation:

```text
docs/VEWRA_MASTER_IMPLEMENTATION_PLAN.md
docs/ARCHITECTURE_DECISIONS.md
```

The current development database decision is now:

```text
Local development: PostgreSQL 16+
Production: PostgreSQL
Database access: Django ORM
Raw SQL: prohibited unless explicitly approved by a future ADR
```

Remove stale statements that identify MySQL/MariaDB as the normal local database.

Do not commit database passwords.

## 3. Environment Configuration

The mobile client must not permanently hardcode a LAN address such as `192.168.1.45`.

Use the already-approved `flutter_dotenv` approach.

Required:

```text
mobile/.env
mobile/.env.example
mobile/lib/core/network/api_constants.dart
mobile/lib/core/network/api_client.dart
```

Example `mobile/.env.example`:

```env
API_BASE_URL=http://192.168.1.45:8000/api/v1
APP_ENV=development
API_CONNECT_TIMEOUT_SECONDS=15
API_RECEIVE_TIMEOUT_SECONDS=15
API_SEND_TIMEOUT_SECONDS=15
```

`mobile/.env` must stay gitignored.

`ApiConstants` must resolve the base URL from environment configuration:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    final value = dotenv.env['API_BASE_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('API_BASE_URL is not configured.');
    }
    return value.endsWith('/')
        ? value.substring(0, value.length - 1)
        : value;
  }
}
```

Django development settings must read PostgreSQL values from `backend/.env`. No password is to be embedded in `development.py`.

## 4. Phase Scope

Implement:

- real task catalogue;
- real task detail;
- task eligibility;
- task attempts;
- video/watch sessions;
- watch-session token;
- heartbeat tracking;
- play/pause/background/foreground event handling;
- server-authoritative credited watch time;
- completion verification;
- quiz foundation;
- reward idempotency;
- wallet credit integration;
- XP award foundation;
- live Flutter Earn feed;
- real Flutter tracking HUD;
- Django admin management;
- automated tests;
- physical-device integration procedure.

Do not implement:

- creator campaign billing;
- P2P marketplace escrow;
- ad networks;
- production payout providers;
- external AI vendor integration;
- social engagement automation;
- automated likes/comments/follows/subscriptions/shares;
- third-party platform scraping or anti-bot circumvention;
- community chat.

## 5. Backend Applications

Create:

```text
backend/apps/tasks/
├── __init__.py
├── apps.py
├── admin.py
├── models.py
├── serializers.py
├── services.py
├── selectors.py
├── permissions.py
├── views.py
├── urls.py
├── quiz_generation.py
├── management/
│   └── commands/
│       └── seed_phase5_test_data.py
├── tests/
│   ├── __init__.py
│   ├── test_models.py
│   ├── test_task_feed_api.py
│   ├── test_task_eligibility.py
│   └── test_task_attempts.py
└── migrations/

backend/apps/tracking/
├── __init__.py
├── apps.py
├── admin.py
├── models.py
├── serializers.py
├── services.py
├── selectors.py
├── views.py
├── urls.py
├── tests/
│   ├── __init__.py
│   ├── test_watch_session.py
│   ├── test_heartbeat_api.py
│   ├── test_completion_verification.py
│   ├── test_reward_idempotency.py
│   └── test_quiz_flow.py
└── migrations/
```

Register both apps in:

```text
backend/config/settings/base.py
```

Register routes in:

```text
backend/config/urls.py
```

## 6. Task Model

File:

```text
backend/apps/tasks/models.py
```

Create choices:

```python
class TaskType(models.TextChoices):
    VIDEO = "VIDEO", "Video"
    SURVEY = "SURVEY", "Survey"
    SOCIAL = "SOCIAL", "Social"
    CHALLENGE = "CHALLENGE", "Challenge"

class TaskStatus(models.TextChoices):
    DRAFT = "DRAFT", "Draft"
    ACTIVE = "ACTIVE", "Active"
    PAUSED = "PAUSED", "Paused"
    EXHAUSTED = "EXHAUSTED", "Exhausted"
    EXPIRED = "EXPIRED", "Expired"
    ARCHIVED = "ARCHIVED", "Archived"
```

Create `Task` with:

```text
id                      UUID primary key
task_type               TaskType
status                  TaskStatus
title                   varchar
slug                    unique slug
description             text
instructions            JSON list
thumbnail_url           URL
source_url              URL
source_platform         varchar
channel_name            varchar blank allowed
search_keywords         text blank allowed

reward_coins            positive bigint/integer
reward_cash             decimal default 0
reward_xp               positive integer default 0

required_watch_seconds  positive integer
quiz_required           boolean
quiz_pass_percentage    integer 0–100

daily_user_limit        positive integer
total_completion_limit  positive integer nullable
total_completions       positive integer default 0

minimum_level           positive integer default 1
minimum_trust_score     integer 0–100
verification_required   boolean

starts_at               datetime nullable
expires_at              datetime nullable

created_by              FK user nullable
created_at
updated_at
```

Add validation so rewards cannot be negative, required watch time must be positive for video tasks, trust and quiz percentages stay between 0 and 100, and completion counts cannot become invalid.

Add indexes on:

```text
status
task_type
starts_at
expires_at
created_at
```

## 7. Task Attempt

Create:

```python
class TaskAttemptStatus(models.TextChoices):
    CREATED = "CREATED", "Created"
    IN_PROGRESS = "IN_PROGRESS", "In Progress"
    AWAITING_QUIZ = "AWAITING_QUIZ", "Awaiting Quiz"
    VERIFYING = "VERIFYING", "Verifying"
    COMPLETED = "COMPLETED", "Completed"
    FAILED = "FAILED", "Failed"
    ABANDONED = "ABANDONED", "Abandoned"
```

`TaskAttempt` fields:

```text
id UUID
user FK
task FK
status
started_at
completed_at nullable
failed_at nullable
reward_granted boolean
reward_granted_at nullable
reward_reference unique nullable
quiz_required boolean
quiz_passed nullable
quiz_score nullable
failure_reason blank
created_at
updated_at
```

Protect against multiple simultaneous active attempts for the same user/task.

## 8. Reward Grant Idempotency Model

Create:

```python
class TaskRewardGrant(models.Model):
    id = models.UUIDField(...)
    user = models.ForeignKey(...)
    task = models.ForeignKey(...)
    attempt = models.OneToOneField(...)
    coins = models.PositiveBigIntegerField(default=0)
    cash = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    xp = models.PositiveIntegerField(default=0)
    wallet_reference = models.CharField(max_length=100, unique=True)
    granted_at = models.DateTimeField(auto_now_add=True)
```

Use deterministic reference:

```text
TASK-<attempt UUID>
```

Repeated completion calls must return the existing grant and must not credit the wallet twice.

## 9. Eligibility Service

File:

```text
backend/apps/tasks/services.py
```

Create:

```python
class TaskEligibilityService:
    @staticmethod
    def check(user, task) -> dict:
        ...
```

Return:

```python
{
    "eligible": True,
    "reasons": [],
    "requirements": {
        "account_active": True,
        "task_active": True,
        "schedule": True,
        "capacity": True,
        "level": True,
        "trust_score": True,
        "verification": True,
        "daily_limit": True,
        "repeat_rule": True,
    }
}
```

Check all of those rules server-side. Do not trust eligibility values sent by Flutter.

## 10. Task Selectors

File:

```text
backend/apps/tasks/selectors.py
```

Create:

```python
def get_available_tasks_for_user(user, task_type=None, search=None, limit=50):
    ...
```

Views must call selectors/services instead of embedding large business queries.

Locked tasks may appear with safe user-facing requirements, but do not expose detailed anti-fraud reasons.

## 11. Watch Session Model

File:

```text
backend/apps/tracking/models.py
```

Create statuses:

```python
class WatchSessionStatus(models.TextChoices):
    ACTIVE = "ACTIVE", "Active"
    PAUSED = "PAUSED", "Paused"
    COMPLETED = "COMPLETED", "Completed"
    INVALID = "INVALID", "Invalid"
    EXPIRED = "EXPIRED", "Expired"
    ABANDONED = "ABANDONED", "Abandoned"
```

Create `WatchSession`:

```text
id UUID
attempt OneToOne
user FK
task FK
session_token_hash
status
started_at
last_heartbeat_at nullable
ended_at nullable
required_seconds
credited_watch_seconds default 0
heartbeat_count default 0
invalid_event_count default 0
client_platform
app_version
device_id_hash blank
client_session_id
last_sequence default 0
last_client_position nullable
created_at
updated_at
```

Store hashed device identifiers where practical instead of raw identifiers.

## 12. Watch Event Log

Create append-only `WatchEvent`:

```text
id
session FK
event_type
sequence
client_timestamp nullable
server_timestamp
playback_position nullable
metadata JSON
```

Events:

```text
SESSION_STARTED
PLAY
PAUSE
HEARTBEAT
APP_BACKGROUND
APP_FOREGROUND
VISIBILITY_LOST
VISIBILITY_RESTORED
PLAYER_ENDED
QUIZ_STARTED
QUIZ_SUBMITTED
SESSION_COMPLETED
SESSION_INVALIDATED
```

Unique constraint:

```text
(session, sequence)
```

## 13. Server-Authoritative Time Rules

The client timer is display/scheduling only.

Initial rules:

```text
heartbeat target interval: 15 seconds
maximum credited heartbeat gap: 30 seconds
no credit while PAUSED
no credit after APP_BACKGROUND until explicit foreground/play transition
duplicate sequence: reject
out-of-order sequence: reject
expired session: reject
credited time cannot exceed required seconds
client playback position never directly determines earned time
```

Put timing values in Django settings/constants:

```text
WATCH_HEARTBEAT_INTERVAL_SECONDS
WATCH_HEARTBEAT_MAX_GAP_SECONDS
WATCH_SESSION_GRACE_MINUTES
```

Use transactions and `select_for_update()` around mutable session state.

## 14. Watch Session Token

Generate a high-entropy token:

```python
import secrets
import hashlib

raw_token = secrets.token_urlsafe(32)
token_hash = hashlib.sha256(raw_token.encode()).hexdigest()
```

Return plaintext token only when the session starts. Store only its hash.

Heartbeat/event/completion requests require:

```http
Authorization: Bearer <JWT>
X-VEWRA-WATCH-TOKEN: <watch-session-token>
```

Never log the token.

## 15. Task Start API

Endpoint:

```http
POST /api/v1/tasks/{task_id}/start/
```

Flow:

```text
authenticate
→ load task
→ eligibility check
→ create/resume safe TaskAttempt
→ create WatchSession
→ create watch token
→ return session configuration
```

Example response:

```json
{
  "status": "success",
  "attempt": {
    "id": "uuid",
    "status": "IN_PROGRESS"
  },
  "watch_session": {
    "id": "uuid",
    "watch_token": "returned-once",
    "required_seconds": 180,
    "credited_watch_seconds": 0,
    "heartbeat_interval_seconds": 15,
    "source_url": "https://example.com/video"
  }
}
```

## 16. Heartbeat API

Endpoint:

```http
POST /api/v1/tracking/sessions/{session_id}/heartbeat/
```

Payload:

```json
{
  "sequence": 4,
  "playback_position": 44.5,
  "client_timestamp": "2026-08-26T12:00:00Z"
}
```

Response:

```json
{
  "status": "success",
  "session": {
    "state": "ACTIVE",
    "credited_watch_seconds": 42,
    "required_seconds": 180,
    "progress_percentage": 23.33,
    "quiz_required": true
  }
}
```

The HUD uses this server state.

## 17. Event API

Endpoint:

```http
POST /api/v1/tracking/sessions/{session_id}/events/
```

Allow only:

```text
PLAY
PAUSE
APP_BACKGROUND
APP_FOREGROUND
PLAYER_ENDED
```

Do not accept arbitrary event names.

## 18. Completion Verification

Endpoint:

```http
POST /api/v1/tracking/sessions/{session_id}/complete/
```

The client requests verification. It does not assert success.

`TrackingVerificationService.verify_completion()` must verify:

```text
session ownership
attempt ownership
session status
required credited watch time
event/sequence integrity
task validity
quiz state
reward idempotency
```

Return one of:

```text
COMPLETED
AWAITING_QUIZ
INCOMPLETE
INVALID
ALREADY_COMPLETED
```

## 19. Wallet Integration

Use existing Phase 4 services only.

Example:

```python
WalletService.credit_coins(
    user=user,
    amount=task.reward_coins,
    transaction_type=CoinTransactionType.REWARD,
    reference=f"TASK-{attempt.id}",
    description=f"Task reward: {task.title}",
)
```

If `reward_cash > 0`, use the existing cash credit service.

Wrap attempt completion, reward grant and wallet transaction in one atomic transaction.

Do not modify `Wallet.coin_balance` directly from task/tracking views.

## 20. XP Foundation

Create:

```python
class TaskRewardService:
    @staticmethod
    def grant_xp(user, amount, reason, reference):
        ...
```

Update profile XP safely with `select_for_update()` or `F()` expressions. Do not invent a full level formula if no authoritative gamification backend level service exists yet.


## 21. Quiz Foundation

The product plan requires post-video AI engagement quizzes. Phase 5 must implement the quiz data flow without locking VEWRA to a particular AI vendor.

Create in:

```text
backend/apps/tasks/models.py
```

### QuizQuestion

Fields:

```text
id UUID
task FK
question_text
question_type
options JSON
correct_answer server-only
explanation blank
source_timestamp_seconds nullable
difficulty
active
created_at
updated_at
```

Phase 5 supported type:

```text
MULTIPLE_CHOICE
```

The correct answer must never appear in public task or quiz serializers.

### QuizAttempt

```text
id UUID
task_attempt OneToOne/controlled relationship
user FK
started_at
submitted_at nullable
score
pass_percentage
passed
```

### QuizAnswer

```text
quiz_attempt FK
question FK
selected_answer
is_correct
```

The server calculates correctness and score.

## 22. Quiz APIs

Required:

```http
GET  /api/v1/tasks/attempts/{attempt_id}/quiz/
POST /api/v1/tasks/attempts/{attempt_id}/quiz/submit/
```

Quiz access is allowed only when the watch requirement is satisfied.

Fetch response example:

```json
{
  "attempt_id": "uuid",
  "pass_percentage": 70,
  "questions": [
    {
      "id": "uuid",
      "question": "Which topic was discussed?",
      "options": ["A", "B", "C", "D"],
      "source_timestamp_seconds": 65
    }
  ]
}
```

Submission:

```json
{
  "answers": [
    {
      "question_id": "uuid",
      "selected_answer": "B"
    }
  ]
}
```

The backend returns score/pass status. A passing result allows completion verification to proceed.

## 23. AI Generation Extension Point

Create:

```text
backend/apps/tasks/quiz_generation.py
```

Interface:

```python
class QuizGenerationProvider:
    def generate_for_task(self, task):
        raise NotImplementedError
```

Create a manual/admin provider if useful.

Do not connect OpenAI, Gemini or any external paid AI service in Phase 5.

A later AI phase must be able to add a provider without redesigning task attempts or quiz storage.

## 24. External Platform Rules

VEWRA's Phase 5 tracking verifies its own session rules.

Do not build mechanisms that fabricate third-party engagement.

Do not automate:

```text
likes
comments
subscriptions
follows
shares
ad clicks
```

Do not scrape protected/login-only third-party pages, bypass anti-bot systems, interfere with adverts or falsify external-platform metrics.

When a task uses YouTube or another platform, use an official or terms-compatible player/integration method.

## 25. Backend Serializers

Create:

```text
backend/apps/tasks/serializers.py
backend/apps/tracking/serializers.py
```

Required task serializers:

```text
TaskListSerializer
TaskDetailSerializer
TaskEligibilitySerializer
TaskAttemptSerializer
QuizQuestionPublicSerializer
QuizSubmissionSerializer
QuizResultSerializer
```

Required tracking serializers:

```text
WatchSessionSerializer
WatchHeartbeatSerializer
WatchEventSerializer
WatchCompletionSerializer
```

Rules:

- authenticated user IDs are derived from `request.user`;
- reward status is read-only;
- correct quiz answers are never exposed;
- session token hashes are never exposed;
- server-calculated watch seconds cannot be submitted as writable values.

## 26. API Routes

`backend/apps/tasks/urls.py`:

```http
GET  /api/v1/tasks/
GET  /api/v1/tasks/{id}/
GET  /api/v1/tasks/{id}/eligibility/
POST /api/v1/tasks/{id}/start/

GET  /api/v1/tasks/attempts/
GET  /api/v1/tasks/attempts/{attempt_id}/
GET  /api/v1/tasks/attempts/{attempt_id}/quiz/
POST /api/v1/tasks/attempts/{attempt_id}/quiz/submit/
```

`backend/apps/tracking/urls.py`:

```http
GET  /api/v1/tracking/sessions/{id}/
POST /api/v1/tracking/sessions/{id}/heartbeat/
POST /api/v1/tracking/sessions/{id}/events/
POST /api/v1/tracking/sessions/{id}/complete/
POST /api/v1/tracking/sessions/{id}/abandon/
```

Register:

```text
path("api/v1/tasks/", include("apps.tasks.urls"))
path("api/v1/tracking/", include("apps.tracking.urls"))
```

## 27. Error Contract

Use a consistent JSON contract:

```json
{
  "status": "error",
  "code": "TASK_NOT_ELIGIBLE",
  "message": "This task is currently locked.",
  "details": {
    "minimum_level": 5
  }
}
```

Codes should include:

```text
TASK_NOT_FOUND
TASK_NOT_ACTIVE
TASK_NOT_ELIGIBLE
TASK_DAILY_LIMIT_REACHED
TASK_CAPACITY_EXHAUSTED
ACTIVE_ATTEMPT_EXISTS
SESSION_NOT_FOUND
SESSION_TOKEN_INVALID
SESSION_EXPIRED
INVALID_SEQUENCE
INSUFFICIENT_WATCH_TIME
QUIZ_REQUIRED
QUIZ_FAILED
REWARD_ALREADY_GRANTED
```

Flutter must map these to user-friendly states.

## 28. Django Admin

`backend/apps/tasks/admin.py` must let an authorised admin:

```text
create/edit tasks
set task status
set reward coins/cash/XP
set required watch duration
set eligibility thresholds
set daily and total completion limits
schedule starts/expiry
add/manage quiz questions
inspect attempts
inspect reward grants
```

`backend/apps/tracking/admin.py`:

```text
inspect sessions
inspect credited watch seconds
inspect event logs
inspect invalid sessions
inspect heartbeat counts
```

Immutable financial/audit fields must be read-only.

## 29. Flutter Task Feature Refactor

Target structure:

```text
mobile/lib/features/tasks/
├── data/
│   ├── task_api_service.dart
│   └── task_repository.dart
├── models/
│   ├── task_model.dart
│   ├── task_attempt_model.dart
│   ├── task_eligibility_model.dart
│   ├── quiz_question_model.dart
│   └── quiz_result_model.dart
├── providers/
│   ├── task_feed_provider.dart
│   ├── task_details_provider.dart
│   └── task_attempt_provider.dart
├── screens/
│   ├── tasks_screen.dart
│   ├── task_details_screen.dart
│   └── quiz_screen.dart
└── widgets/
    ├── task_card.dart
    ├── task_requirement_chip.dart
    ├── task_reward_summary.dart
    └── task_locked_overlay.dart
```

The repository currently has `mobile/lib/models/task_model.dart`. Migrate it carefully into the task feature or extend the existing model in one authoritative location. Do not leave duplicate competing `TaskModel` classes.

The live Earn screen must stop reading `DummyDataService.tasks`.

## 30. Flutter Tracking Feature

Target:

```text
mobile/lib/features/browser/
├── data/
│   ├── tracking_api_service.dart
│   └── tracking_repository.dart
├── models/
│   ├── watch_session_model.dart
│   ├── watch_progress_model.dart
│   └── watch_completion_model.dart
├── providers/
│   └── tracking_session_provider.dart
├── screens/
│   └── browser_screen.dart
└── widgets/
    ├── browser_top_bar.dart
    ├── tracking_hud.dart
    ├── tracking_status_banner.dart
    └── task_completion_dialog.dart
```

Remove the current local simulated reward timer/completion authority from `browser_screen.dart`.

A local timer may schedule heartbeats, but reward progress must be synchronised from server responses.

## 31. Player/WebView Integration

Inspect platform requirements before selecting the package.

For approved ordinary web content, a compatible pinned `webview_flutter` version may be used.

For YouTube or similar services, prefer an official embed/player-compatible method.

Do not blindly upgrade established dependencies such as Riverpod, Dio, secure storage or dotenv while adding the player package.

The player layer must allow VEWRA to observe enough lifecycle information to send:

```text
PLAY
PAUSE
APP_BACKGROUND
APP_FOREGROUND
PLAYER_ENDED
```

## 32. Flutter API Constants

Add paths such as:

```dart
static const String tasks = '/tasks/';
static String taskDetails(String id) => '/tasks/$id/';
static String taskEligibility(String id) => '/tasks/$id/eligibility/';
static String taskStart(String id) => '/tasks/$id/start/';

static const String taskAttempts = '/tasks/attempts/';
static String taskAttempt(String id) => '/tasks/attempts/$id/';
static String taskQuiz(String id) => '/tasks/attempts/$id/quiz/';
static String taskQuizSubmit(String id) =>
    '/tasks/attempts/$id/quiz/submit/';

static String trackingSession(String id) => '/tracking/sessions/$id/';
static String trackingHeartbeat(String id) =>
    '/tracking/sessions/$id/heartbeat/';
static String trackingEvents(String id) =>
    '/tracking/sessions/$id/events/';
static String trackingComplete(String id) =>
    '/tracking/sessions/$id/complete/';
static String trackingAbandon(String id) =>
    '/tracking/sessions/$id/abandon/';
```

Base URL remains environment-derived.

## 33. Task Feed Behaviour

The real Earn screen must support:

```text
loading
API error
empty feed
pull-to-refresh
task category filter
search
locked eligibility indication
reward preview
task type
required duration
quiz-required badge
```

Cached task data may be displayed for UX, but stale cache must not be treated as proof that a task can still be started.

## 34. Task Details Behaviour

Display:

```text
title
description
thumbnail
source/channel
instructions
reward coins
reward XP
reward cash if applicable
required watch duration
quiz requirement
minimum level
trust requirement
verification requirement
availability
```

Start button flow:

```text
tap Start
→ call backend start endpoint
→ receive attempt/session/watch token
→ navigate to tracker
```

Do not start an earning timer before server acceptance.

## 35. Tracking Riverpod State

Create an explicit state model:

```dart
enum TrackingSessionStatus {
  idle,
  starting,
  active,
  paused,
  awaitingQuiz,
  verifying,
  completed,
  invalid,
  error,
}
```

State contains:

```text
session
creditedWatchSeconds
requiredSeconds
progressPercentage
lastSuccessfulHeartbeat
sequence
watchToken
error
```

Do not log the watch token.

## 36. Heartbeat Lifecycle

Flutter scheduler:

```text
start only when ACTIVE
send at server-configured interval
increase sequence monotonically
stop when paused/backgrounded/completed/disposed
resume after explicit foreground/play state
```

On app lifecycle pause/inactive/detach:

- send best-effort `APP_BACKGROUND`;
- stop heartbeat scheduler.

On resume:

- send `APP_FOREGROUND`;
- resume only after valid player/session state.

Network errors must never fabricate elapsed watch time.

## 37. Completion UX

Replace any unconditional local message such as:

```text
Task Verified!
Your balance has been updated.
```

with backend-driven behaviour:

```text
server returns INCOMPLETE
→ continue session

server returns AWAITING_QUIZ
→ open quiz

server returns COMPLETED
→ show actual granted reward
→ refresh walletProvider

server returns INVALID
→ show failure/retry guidance
```

Only display “coins credited” after backend confirmation.

## 38. Quiz Flutter Screen

Create:

```text
mobile/lib/features/tasks/screens/quiz_screen.dart
```

Requirements:

```text
fetch quiz from API
render multiple-choice questions
never receive correct answer in model
submit answers
show server-calculated score
if passed, request completion verification
show reward only from server response
```

## 39. Wallet Refresh

After a successful task reward:

```text
backend WalletService credits wallet
→ completion API returns grant
→ Flutter invalidates/refetches walletProvider
```

Do not locally increment the wallet balance.

## 40. Concurrency and Idempotency

Protect against double rewards.

Use:

```text
transaction.atomic
select_for_update
TaskRewardGrant attempt OneToOne
unique wallet reference
```

Repeated `/complete/` calls must return the same grant.

Test parallel/repeated completion behaviour.

## 41. Session Expiry

Use central settings such as:

```python
WATCH_HEARTBEAT_INTERVAL_SECONDS = 15
WATCH_HEARTBEAT_MAX_GAP_SECONDS = 30
WATCH_SESSION_GRACE_MINUTES = 30
```

Session max age should consider required watch duration plus grace.

Do not scatter magic numbers throughout services.

## 42. Logging

Log:

```text
task start
session creation
invalid sequence
session invalidation
completion verification
reward grant
idempotent repeated completion
```

Never log:

```text
passwords
JWT tokens
watch tokens
raw sensitive device identifiers
```

## 43. Backend Tests

Mandatory coverage:

### Task catalogue
- create task;
- reject invalid reward/watch values;
- expired/inactive eligibility;
- task feed authentication;
- filters and search.

### Eligibility
- level threshold;
- trust threshold;
- verification;
- daily limit;
- global capacity;
- repeat rule.

### Start
- session creation;
- duplicate active attempt handling;
- token returned once;
- plaintext token not stored.

### Tracking
- heartbeat credits bounded time;
- duplicate sequence rejected;
- out-of-order rejected;
- paused session earns no time;
- background state earns no time;
- large gap capped;
- credited time cannot exceed required time.

### Completion
- insufficient time rejected;
- enough time accepted;
- quiz requirement enforced;
- abandoned/invalid sessions rejected.

### Quiz
- correct answers pass;
- incorrect answers fail;
- correct answers are absent from public API.

### Reward
- wallet credited;
- CoinTransaction created;
- TaskRewardGrant created;
- repeated completion credits once.

## 44. Flutter Tests

Create/update:

```text
mobile/test/features/tasks/task_api_service_test.dart
mobile/test/features/tasks/task_repository_test.dart
mobile/test/features/tasks/task_feed_provider_test.dart
mobile/test/features/tasks/task_attempt_provider_test.dart
mobile/test/features/tasks/tasks_screen_test.dart
mobile/test/features/tasks/task_details_screen_test.dart
mobile/test/features/tasks/quiz_screen_test.dart

mobile/test/features/browser/tracking_api_service_test.dart
mobile/test/features/browser/tracking_repository_test.dart
mobile/test/features/browser/tracking_session_provider_test.dart
mobile/test/features/browser/browser_screen_test.dart
mobile/test/features/browser/tracking_hud_test.dart
```

Test loading, error, empty, locked, start, server progress, pause/resume, invalid session, quiz and wallet refresh.

Use mocks/fakes. Unit/widget tests should not require the live development server.

## 45. End-to-End Backend Test

Add an integration flow:

```text
create user
→ authenticate
→ fetch task
→ start
→ send valid heartbeats
→ satisfy watch requirement
→ fetch/submit quiz if required
→ complete
→ verify TaskRewardGrant
→ verify Wallet balance
→ verify CoinTransaction
```

Use test-time mocking or very short test durations. Never wait real minutes in automated tests.

## 46. Test Data Seeder

Create:

```text
backend/apps/tasks/management/commands/seed_phase5_test_data.py
```

It must use `update_or_create`.

Seed a few development tasks with short watch duration and quiz questions.

It must never run automatically in production.

Command:

```powershell
python manage.py seed_phase5_test_data
```

## 47. Migrations

After models stabilise:

```powershell
python manage.py makemigrations tasks tracking
python manage.py migrate
```

Do not delete/rewrite previously applied Phase 1–4 migrations.

Verify against PostgreSQL.

## 48. API Documentation

Create:

```text
docs/api/PHASE_05_TASK_TRACKING_API.md
```

For every endpoint document:

```text
HTTP method
path
authentication
required headers
request fields
success response
error codes
```

Document `X-VEWRA-WATCH-TOKEN` without using real tokens.

## 49. Physical Device Test

After automated tests:

1. Ensure PostgreSQL service is running.
2. Run Django:
   ```powershell
   python manage.py runserver 0.0.0.0:8000
   ```
3. Set `mobile/.env` to the current computer LAN API address.
4. Seed/create a short test task.
5. Build:
   ```powershell
   flutter build apk --debug
   ```
6. Install:
   ```powershell
   flutter install --debug -d <DEVICE_ID>
   ```
7. Login on the physical device.
8. Open Earn and confirm live backend tasks.
9. Start a task.
10. Confirm heartbeat requests appear in Django logs.
11. Pause/background app and confirm watch credit pauses.
12. Resume.
13. Reach required server time.
14. Complete quiz if required.
15. Complete task.
16. Confirm wallet refresh.
17. Confirm transaction and reward grant in Django admin.
18. Call completion again and confirm no duplicate reward.

## 50. Required Verification Commands

Backend:

```powershell
python manage.py check
python manage.py makemigrations --check
python manage.py test apps
```

Flutter:

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Do not report completion with failing checks.

## 51. Documentation at Completion

Create:

```text
docs/PHASE_05_COMPLETION_REVIEW.md
```

Record actual:

```text
files created/modified
models and migrations
API routes
tracking rules
quiz flow
wallet integration
test counts/results
physical-device results
deferred items
```

## 52. Git Safety

Before commit:

```powershell
git status
```

Confirm no:

```text
backend/.env
mobile/.env
PostgreSQL password
JWT/watch token
database dump
unintended APK binary
```

is being committed.

Suggested commit:

```text
feat: implement Phase 5 task tracking and reward verification engine
```

Push to `origin main`.

## 53. Completion Criteria

Phase 5 is complete only when:

### Backend
- tasks app exists;
- tracking app exists;
- PostgreSQL task catalogue works;
- eligibility is server-side;
- attempts persist;
- watch sessions/events persist;
- watch time is server-authoritative;
- invalid event sequences are handled;
- completion is server verified;
- quiz foundation works;
- reward is idempotent;
- WalletService handles reward credit;
- task completion has ledger history.

### Flutter
- live Earn feed replaces mock task feed;
- task details comes from API;
- starting creates server attempt/session;
- browser/tracker uses actual compatible player integration;
- HUD uses server progress;
- lifecycle events are sent;
- quiz works;
- reward dialog is backend-driven;
- wallet refreshes after reward.

### Quality
- backend tests pass;
- Flutter tests pass;
- static analysis is clean;
- debug APK builds;
- physical-device flow works;
- repeated completion never double-credits.

### Documentation
- PostgreSQL architecture is synchronised;
- Phase 5 API document exists;
- completion review exists.

## 54. Deferred Work

Leave these for later phases:

```text
creator promotion campaign billing
managed promotion pricing
SMM panel
external AI quiz generation
advanced device-integrity/fraud enforcement
ad SDK
payment/payout providers
P2P coin escrow
community messaging
full gamification backend engine
production analytics
```

## 55. Final Rule

The Flutter client displays earning progress. The Django backend creates financial truth.

No task reward exists until the backend has verified the attempt and recorded an idempotent wallet-backed reward grant.

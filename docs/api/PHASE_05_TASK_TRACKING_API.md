# VEWRA Phase 5 API Documentation — Task Video Tracking, Verification & Reward Engine

This document provides the authoritative API specification for the **Task Discovery**, **Session Tracking**, **Interactive Quizzes**, and **Reward Granting Engine** in VEWRA Phase 5.

---

## Base URL
- Local / Emulator: `http://127.0.0.1:8000/api/v1`
- LAN / Wi-Fi Device: `http://<LAN_IP>:8000/api/v1`

---

## 1. Task Discovery & Detail Endpoints

### 1.1 List Available Tasks
- **URL**: `/tasks/`
- **Method**: `GET`
- **Authentication**: Optional (returns public catalog); authenticated requests include user-specific completion flags.
- **Query Parameters**:
  - `type` (optional): `VIDEO`, `SURVEY`, `SOCIAL`, `CHALLENGE`
  - `search` (optional): search string matching task title, channel name, or description.
- **Response**: `200 OK`
```json
{
  "status": "success",
  "count": 3,
  "tasks": [
    {
      "id": "a50db89d-4345-4ae2-a25e-e47854659eb8",
      "title": "Flutter Clean Architecture Masterclass",
      "slug": "flutter-clean-architecture-masterclass",
      "task_type": "VIDEO",
      "status": "ACTIVE",
      "description": "Watch the complete architecture overview and verify your understanding.",
      "instructions": [
        "Keep the video player visible in the viewport.",
        "Accumulate the full required watch duration.",
        "Pass the verification quiz to claim your coins."
      ],
      "thumbnail_url": "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe",
      "source_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "source_platform": "YouTube",
      "channel_name": "Flutter Devs Official",
      "reward_coins": 25,
      "reward_cash": "0.00",
      "reward_xp": 25,
      "required_watch_seconds": 60,
      "quiz_required": true,
      "quiz_pass_percentage": 70,
      "minimum_level": 1,
      "minimum_trust_score": 50,
      "verification_required": false,
      "created_at": "2026-08-26T12:00:00Z",
      "is_completed": false
    }
  ]
}
```

---

### 1.2 Task Details & Server Eligibility
- **URL**: `/tasks/<task_id_or_slug>/`
- **Method**: `GET`
- **Authentication**: Optional / Authenticated
- **Response**: `200 OK`
```json
{
  "status": "success",
  "task": {
    "id": "a50db89d-4345-4ae2-a25e-e47854659eb8",
    "title": "Flutter Clean Architecture Masterclass",
    "slug": "flutter-clean-architecture-masterclass",
    "task_type": "VIDEO",
    "reward_coins": 25,
    "required_watch_seconds": 60,
    "quiz_required": true
  },
  "eligibility": {
    "eligible": true,
    "reasons": [],
    "requirements": {
      "account_active": true,
      "task_active": true,
      "schedule": true,
      "capacity": true,
      "level": true,
      "trust_score": true,
      "verification": true,
      "daily_limit": true,
      "repeat_rule": true
    },
    "active_attempt_id": null
  }
}
```

---

### 1.3 Start Task Session
- **URL**: `/tasks/<task_id>/start/`
- **Method**: `POST`
- **Authentication**: Required (`Bearer <access_token>`)
- **Headers**:
  - `Content-Type: application/json`
- **Request Body**:
```json
{
  "client_platform": "MOBILE",
  "app_version": "1.0.0"
}
```
- **Response**: `201 Created`
```json
{
  "status": "success",
  "message": "Task started successfully.",
  "attempt": {
    "id": "b18b456f-8703-4f9e-a89c-d2617dfb119a",
    "task_id": "a50db89d-4345-4ae2-a25e-e47854659eb8",
    "task_title": "Flutter Clean Architecture Masterclass",
    "reward_coins": 25,
    "status": "IN_PROGRESS",
    "started_at": "2026-08-26T12:05:00Z",
    "quiz_required": true
  },
  "watch_session": {
    "id": "783262d1-e945-4e78-9e5c-cb319d640242",
    "attempt_id": "b18b456f-8703-4f9e-a89c-d2617dfb119a",
    "task_id": "a50db89d-4345-4ae2-a25e-e47854659eb8",
    "status": "ACTIVE",
    "required_seconds": 60,
    "credited_watch_seconds": 0,
    "progress_percentage": 0.0,
    "is_satisfied": false,
    "last_sequence": 1,
    "watch_token": "sECrEt_wAtCh_tOkEn_32_bYtEs_uRlSaFe",
    "quiz_required": true
  }
}
```

---

## 2. Server-Authoritative Video Tracking

### 2.1 Heartbeat Ping
- **URL**: `/tracking/sessions/<session_id>/heartbeat/`
- **Method**: `POST`
- **Authentication**: Required (`Bearer <access_token>`)
- **Headers**:
  - `X-VEWRA-WATCH-TOKEN: <watch_token>`
  - `Content-Type: application/json`
- **Request Body**:
```json
{
  "sequence": 2,
  "playback_position": 15.0,
  "client_timestamp": "2026-08-26T12:05:15Z"
}
```
- **Response**: `200 OK`
```json
{
  "status": "success",
  "session": {
    "id": "783262d1-e945-4e78-9e5c-cb319d640242",
    "state": "ACTIVE",
    "credited_watch_seconds": 15,
    "required_seconds": 60,
    "progress_percentage": 25.0,
    "quiz_required": true,
    "is_satisfied": false
  }
}
```

---

### 2.2 Lifecycle & Player Events
- **URL**: `/tracking/sessions/<session_id>/events/`
- **Method**: `POST`
- **Authentication**: Required (`Bearer <access_token>`)
- **Headers**:
  - `X-VEWRA-WATCH-TOKEN: <watch_token>`
- **Request Body**:
```json
{
  "event_type": "APP_BACKGROUND",
  "sequence": 3,
  "playback_position": 15.0
}
```
- **Response**: `200 OK`
```json
{
  "status": "success",
  "message": "Event recorded.",
  "event_type": "APP_BACKGROUND",
  "session_state": "PAUSED"
}
```

---

### 2.3 Verification & Completion
- **URL**: `/tracking/sessions/<session_id>/complete/`
- **Method**: `POST`
- **Authentication**: Required (`Bearer <access_token>`)
- **Headers**:
  - `X-VEWRA-WATCH-TOKEN: <watch_token>`
- **Response (When Quiz Required)**: `200 OK`
```json
{
  "status": "AWAITING_QUIZ",
  "message": "Watch duration requirement met. Verification quiz required.",
  "attempt_id": "b18b456f-8703-4f9e-a89c-d2617dfb119a"
}
```
- **Response (When Complete & Rewarded)**: `200 OK`
```json
{
  "status": "COMPLETED",
  "message": "Task verified and reward granted successfully.",
  "attempt_id": "b18b456f-8703-4f9e-a89c-d2617dfb119a",
  "reward": {
    "coins": 25,
    "cash": "0.00",
    "xp": 25,
    "reference": "TASK-b18b456f-8703-4f9e-a89c-d2617dfb119a"
  }
}
```

---

## 3. Quiz Endpoints

### 3.1 Fetch Quiz Questions
- **URL**: `/tasks/attempts/<attempt_id>/quiz/`
- **Method**: `GET`
- **Authentication**: Required
- **Response**: `200 OK`
```json
{
  "status": "success",
  "attempt_id": "b18b456f-8703-4f9e-a89c-d2617dfb119a",
  "pass_percentage": 70,
  "questions": [
    {
      "id": "1b08e2f6-8c43-4e4b-bb15-3eb97c2763ec",
      "question_text": "What core design pattern is emphasized for state management?",
      "question_type": "MULTIPLE_CHOICE",
      "options": ["MVC", "Riverpod StateNotifier", "Raw setState", "Singleton Bus"],
      "source_timestamp_seconds": 30,
      "difficulty": "MEDIUM"
    }
  ]
}
```

---

### 3.2 Submit Quiz Answers
- **URL**: `/tasks/attempts/<attempt_id>/quiz/submit/`
- **Method**: `POST`
- **Authentication**: Required
- **Request Body**:
```json
{
  "answers": [
    {
      "question_id": "1b08e2f6-8c43-4e4b-bb15-3eb97c2763ec",
      "selected_answer": "Riverpod StateNotifier"
    }
  ]
}
```
- **Response (Passed)**: `200 OK`
```json
{
  "status": "success",
  "attempt_id": "b18b456f-8703-4f9e-a89c-d2617dfb119a",
  "score": 100.0,
  "pass_percentage": 70,
  "passed": true,
  "total_questions": 1,
  "correct_answers": 1,
  "message": "Congratulations! You passed the verification quiz."
}
```

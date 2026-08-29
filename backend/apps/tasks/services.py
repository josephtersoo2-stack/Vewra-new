import os
import re
import json
import uuid
import random
import logging
import requests
from decimal import Decimal
from django.db import transaction
from django.db.models import F
from django.utils import timezone
from django.core.exceptions import ValidationError
from django.contrib.auth import get_user_model
from apps.wallet.services import WalletService
from apps.wallet.models import CoinTransactionType, CashTransactionType
from .models import (
    Task,
    TaskType,
    TaskStatus,
    TaskAttempt,
    TaskAttemptStatus,
    TaskRewardGrant,
    QuizQuestion,
    QuizAttempt,
    QuizAnswer,
)

logger = logging.getLogger(__name__)
User = get_user_model()

class TaskEligibilityService:
    """
    Evaluates server-authoritative eligibility for a user attempting a task.
    """
    @staticmethod
    def check(user, task: Task) -> dict:
        now = timezone.now()
        reasons = []
        
        # 1. Account active check
        account_active = user.is_authenticated and user.is_active
        if not account_active:
            reasons.append("User account is inactive or not authenticated.")

        # 2. Task active status
        task_active = task.status == TaskStatus.ACTIVE
        if not task_active:
            reasons.append(f"Task is currently {task.status.lower()}.")

        # 3. Schedule constraints
        schedule = True
        if task.starts_at and now < task.starts_at:
            schedule = False
            reasons.append("Task has not started yet.")
        if task.expires_at and now > task.expires_at:
            schedule = False
            reasons.append("Task has expired.")

        # 4. Global Capacity
        capacity = True
        if task.total_completion_limit is not None and task.total_completions >= task.total_completion_limit:
            capacity = False
            reasons.append("Task global completion limit reached.")

        # 5. User Level threshold
        profile = getattr(user, 'profile', None)
        user_level = getattr(profile, 'level', 1) if profile else 1
        level_ok = user_level >= task.minimum_level
        if not level_ok:
            reasons.append(f"Requires minimum level {task.minimum_level} (your level: {user_level}).")

        # 6. Trust Score threshold
        user_trust = getattr(profile, 'trust_score', 80) if profile else 80
        trust_ok = user_trust >= task.minimum_trust_score
        if not trust_ok:
            reasons.append(f"Requires minimum trust score {task.minimum_trust_score} (your score: {user_trust}).")

        # 7. Verification / KYC requirement
        verification_ok = True
        if task.verification_required:
            ver_status = getattr(user, 'verification_status', 'Basic')
            ver_record = getattr(user, 'verification', None)
            is_verified = (ver_status in ['Verified', 'Trusted']) or (ver_record and ver_record.status == 'APPROVED')
            if not is_verified:
                verification_ok = False
                reasons.append("KYC identity verification required to unlock this task.")

        # 8. Daily User Limit (Controls whether new reward is earnable, but never restricts watching)
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        today_completions = TaskAttempt.objects.filter(
            user=user,
            task=task,
            status=TaskAttemptStatus.COMPLETED,
            completed_at__gte=today_start
        ).count()
        already_completed = today_completions >= task.daily_user_limit
        daily_ok = True  # Always allow watching even if already rewarded

        # 9. Repeat / Active Attempt Rule
        repeat_ok = True
        active_attempt = TaskAttempt.objects.filter(
            user=user,
            task=task,
            status__in=[
                TaskAttemptStatus.CREATED,
                TaskAttemptStatus.IN_PROGRESS,
                TaskAttemptStatus.AWAITING_QUIZ,
                TaskAttemptStatus.VERIFYING,
            ]
        ).first()

        eligible = (
            account_active and
            task_active and
            schedule and
            capacity and
            level_ok and
            trust_ok and
            verification_ok
        )

        return {
            "eligible": eligible,
            "already_completed": already_completed,
            "reasons": reasons,
            "requirements": {
                "account_active": account_active,
                "task_active": task_active,
                "schedule": schedule,
                "capacity": capacity,
                "level": level_ok,
                "trust_score": trust_ok,
                "verification": verification_ok,
                "daily_limit": not already_completed,
                "repeat_rule": repeat_ok,
            },
            "active_attempt_id": str(active_attempt.id) if active_attempt else None,
        }


class TaskRewardService:
    """
    Handles idempotent task reward calculation, wallet ledger integration, and XP granting.
    """
    @staticmethod
    @transaction.atomic
    def grant_reward(attempt: TaskAttempt) -> TaskRewardGrant:
        """
        Atomically grant rewards for a verified task attempt.
        Idempotent: If reward was already granted, returns existing grant without duplicate credit.
        """
        # Lock attempt
        attempt = TaskAttempt.objects.select_for_update().get(id=attempt.id)
        task = Task.objects.select_for_update().get(id=attempt.task_id)

        # Check existing grant
        existing_grant = TaskRewardGrant.objects.filter(attempt=attempt).first()
        if existing_grant or attempt.reward_granted:
            logger.info("Reward already granted for attempt %s, returning existing grant.", attempt.id)
            return existing_grant

        wallet_ref = f"TASK-{attempt.id}"

        # Calculate coins based on reward_type
        coins_to_grant = task.reward_coins
        if task.reward_type == 'per_time':
            watch_session = getattr(attempt, 'watch_session', None)
            credited = watch_session.credited_watch_seconds if watch_session else task.required_watch_seconds
            cfg = task.reward_config if isinstance(task.reward_config, dict) else {}
            interval = int(cfg.get('interval_seconds') or task.required_watch_seconds or 60)
            per_interval = int(cfg.get('coins_per_interval') or task.reward_coins or 10)
            intervals_completed = credited // max(1, interval)
            if intervals_completed > 0:
                coins_to_grant = intervals_completed * per_interval

        # 1. Credit Coins via WalletService
        if coins_to_grant > 0:
            WalletService.credit_coins(
                user=attempt.user,
                amount=coins_to_grant,
                transaction_type=CoinTransactionType.REWARD,
                reference=wallet_ref,
                description=f"Task reward: {task.title}",
            )

        # 2. Credit Cash if applicable
        if task.reward_cash > Decimal('0.00'):
            WalletService.credit_cash(
                user=attempt.user,
                amount=task.reward_cash,
                transaction_type=CashTransactionType.REWARD,
                reference=wallet_ref,
                description=f"Task fiat reward: {task.title}",
            )

        # 3. Grant XP
        if task.reward_xp > 0:
            TaskRewardService.grant_xp(
                user=attempt.user,
                amount=task.reward_xp,
                reason=f"Task completed: {task.title}",
                reference=wallet_ref,
            )

        # 4. Create TaskRewardGrant
        grant = TaskRewardGrant.objects.create(
            user=attempt.user,
            task=task,
            attempt=attempt,
            coins=coins_to_grant,
            cash=task.reward_cash,
            xp=task.reward_xp,
            wallet_reference=wallet_ref,
        )

        # 5. Update Task and Attempt state
        task.total_completions = F('total_completions') + 1
        task.save(update_fields=['total_completions'])

        attempt.status = TaskAttemptStatus.COMPLETED
        attempt.completed_at = timezone.now()
        attempt.reward_granted = True
        attempt.reward_granted_at = timezone.now()
        attempt.reward_reference = wallet_ref
        attempt.save()

        logger.info("Granted %s coins for attempt %s (ref: %s)", coins_to_grant, attempt.id, wallet_ref)
        return grant

    @staticmethod
    def grant_xp(user, amount: int, reason: str = "", reference: str = ""):
        """
        Grant experience points (XP) to user profile.
        """
        if amount <= 0:
            return
        if hasattr(user, 'profile'):
            user.profile.xp = F('xp') + amount
            user.profile.save(update_fields=['xp'])


class TaskAttemptService:
    """
    Manages task attempt lifecycle and initiation.
    """
    @staticmethod
    def get_or_create_attempt(user, task: Task) -> tuple[TaskAttempt, bool]:
        """
        Retrieves an ongoing attempt or creates a new one after validating eligibility.
        """
        # Look for existing in-progress attempt
        existing = TaskAttempt.objects.filter(
            user=user,
            task=task,
            status__in=[
                TaskAttemptStatus.CREATED,
                TaskAttemptStatus.IN_PROGRESS,
                TaskAttemptStatus.AWAITING_QUIZ,
                TaskAttemptStatus.VERIFYING,
            ]
        ).first()

        if existing:
            return existing, False

        # Validate eligibility before creating new attempt
        eligibility = TaskEligibilityService.check(user, task)
        if not eligibility["eligible"]:
            raise ValidationError("; ".join(eligibility["reasons"]) or "User is not eligible for this task.")

        attempt = TaskAttempt.objects.create(
            user=user,
            task=task,
            status=TaskAttemptStatus.IN_PROGRESS,
            quiz_required=task.quiz_required,
        )
        return attempt, True


import re
import random
from urllib.parse import urlparse, parse_qs

YOUTUBE_REGEX = re.compile(
    r'(?:https?:\/\/)?(?:www\.|m\.)?(?:youtube\.com\/(?:watch\?(?:.*&)?v=|embed\/|v\/|shorts\/)|youtu\.be\/)([\w-]{11})',
    re.IGNORECASE
)

def extract_youtube_video_id(url: str) -> str:
    """
    Extract 11-character YouTube video ID from various URL formats.
    """
    if not url:
        return ""
    
    url = url.strip()
    match = YOUTUBE_REGEX.search(url)
    if match:
        return match.group(1)
    
    try:
        parsed = urlparse(url)
        if 'youtube' in parsed.netloc:
            qs = parse_qs(parsed.query)
            if 'v' in qs and qs['v']:
                return qs['v'][0]
    except Exception:
        pass

    if len(url) == 11 and re.match(r'^[\w-]+$', url):
        return url

    return ""

def extract_youtube_metadata(url_or_id: str) -> dict:
    """
    Fetches comprehensive video metadata including direct YouTube URL, title, channel name,
    thumbnail, description snippet, and metadata tags via YouTube oEmbed and web parsing.
    """
    import requests
    video_id = extract_youtube_video_id(url_or_id)
    if not video_id:
        raise ValueError(f"Invalid YouTube URL or Video ID: '{url_or_id}'")

    video_url = f"https://www.youtube.com/watch?v={video_id}"

    meta = {
        'video_id': video_id,
        'url': video_url,
        'video_url': video_url,
        'title': '',
        'channel': '',
        'author_name': '',
        'thumbnail_url': f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg",
        'description': '',
        'tags': [],
    }

    # 1. Fetch YouTube oEmbed API for verified Title, Author Name, Thumbnail
    try:
        oembed_url = f"https://www.youtube.com/oembed?url={video_url}&format=json"
        res = requests.get(oembed_url, timeout=6)
        if res.status_code == 200:
            data = res.json()
            meta['title'] = data.get('title', '').strip()
            meta['channel'] = data.get('author_name', '').strip()
            meta['author_name'] = data.get('author_name', '').strip()
            if data.get('thumbnail_url'):
                meta['thumbnail_url'] = data.get('thumbnail_url')
    except Exception as e:
        logger.warning(f"YouTube oEmbed fetch error for {video_id}: {e}")

    # 2. Scrape YouTube watch page for description fallback
    try:
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Accept-Language": "en-US,en;q=0.9",
        }
        res = requests.get(video_url, headers=headers, timeout=6)
        if res.status_code == 200:
            html = res.text
            if not meta['title']:
                title_match = re.search(r'<title>(.*?)</title>', html, re.IGNORECASE)
                if title_match:
                    meta['title'] = title_match.group(1).replace(' - YouTube', '').strip()

            desc_match = (
                re.search(r'<meta\s+name="description"\s+content="([^"]*)"', html, re.IGNORECASE) or
                re.search(r'<meta\s+property="og:description"\s+content="([^"]*)"', html, re.IGNORECASE)
            )
            if desc_match:
                meta['description'] = desc_match.group(1).strip()
    except Exception as e:
        logger.warning(f"YouTube watch page scrape error for {video_id}: {e}")

    # Generate top-ranking keywords pool using OpenRouter AI & Transcript
    meta['keywords'] = generate_ai_youtube_keywords(
        video_id=video_id,
        title=meta['title'],
        channel=meta['channel'],
        description=meta.get('description', ''),
    )
    return meta


def extract_youtube_transcript(video_id: str) -> str:
    """
    Extracts video transcript/captions using youtube-transcript-api.
    Returns concatenated text or empty string if disabled/unavailable.
    """
    if not video_id:
        return ""
    try:
        from youtube_transcript_api import YouTubeTranscriptApi
        transcript_list = YouTubeTranscriptApi.get_transcript(video_id, languages=['en', 'en-US', 'en-GB', 'a.en'])
        text_chunks = [item['text'] for item in transcript_list if item.get('text')]
        return " ".join(text_chunks)[:4000]
    except Exception as e:
        logger.info("Transcript unavailable for YouTube video %s: %s", video_id, e)
        return ""


def fetch_openrouter_models_list(force_refresh: bool = False) -> list[dict]:
    """
    Fetches the live list of all AI models directly from OpenRouter API without hardcoding.
    Caches results on AIProviderConfig and allows instant refresh.
    """
    from apps.ai.models import AIProviderConfig
    config = AIProviderConfig.get_active_config()

    if not force_refresh and config.cached_models and config.last_models_fetched_at:
        return config.cached_models

    base_url = (config.base_url or "https://openrouter.ai/api/v1").rstrip('/')
    api_key = (config.api_key or os.getenv('OPENROUTER_API_KEY', '')).strip()

    headers = {
        "HTTP-Referer": config.site_url or "https://vewra.com",
        "X-Title": config.site_name or "Vewra Platform",
    }
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"

    try:
        res = requests.get(f"{base_url}/models", headers=headers, timeout=12)
        if res.status_code == 200:
            data = res.json().get('data', [])
            models_list = []
            for item in data:
                m_id = item.get('id')
                m_name = item.get('name', m_id)
                m_ctx = item.get('context_length', 0)
                if m_id:
                    models_list.append({
                        'id': m_id,
                        'name': m_name,
                        'context_length': m_ctx,
                        'description': item.get('description', '')[:100],
                    })
            if models_list:
                # Sort alphabetically by name
                models_list.sort(key=lambda x: x['name'].lower())
                config.cached_models = models_list
                config.last_models_fetched_at = timezone.now()
                config.save(update_fields=['cached_models', 'last_models_fetched_at'])
                return models_list
    except Exception as e:
        logger.warning("Failed to fetch models from OpenRouter API: %s", e)

    return config.cached_models or []


def call_openrouter(prompt: str, model: str = None, system_prompt: str = None) -> str:
    """
    Executes a prompt against the OpenRouter AI chat completions API.
    """
    from apps.ai.models import AIProviderConfig
    config = AIProviderConfig.get_active_config()
    
    api_key = (config.api_key or os.getenv('OPENROUTER_API_KEY', '')).strip()
    if not api_key or not config.is_active:
        raise ValueError("OpenRouter API key is not configured or AI provider is disabled.")

    target_model = model or config.youtube_keyword_model or "google/gemini-2.0-flash-001"
    base_url = (config.base_url or "https://openrouter.ai/api/v1").rstrip('/')

    headers = {
        "Authorization": f"Bearer {api_key}",
        "HTTP-Referer": config.site_url or "https://vewra.com",
        "X-Title": config.site_name or "Vewra Platform",
        "Content-Type": "application/json",
    }

    messages = []
    if system_prompt:
        messages.append({"role": "system", "content": system_prompt})
    messages.append({"role": "user", "content": prompt})

    payload = {
        "model": target_model,
        "messages": messages,
        "temperature": 0.3,
        "max_tokens": 800,
    }

    response = requests.post(
        f"{base_url}/chat/completions",
        headers=headers,
        json=payload,
        timeout=15,
    )
    if response.status_code != 200:
        raise ValueError(f"OpenRouter API error ({response.status_code}): {response.text}")

    data = response.json()
    choices = data.get('choices', [])
    if not choices:
        raise ValueError("No response choices returned by OpenRouter.")

    return choices[0].get('message', {}).get('content', '').strip()


def generate_ai_youtube_keywords(video_id: str, title: str, channel: str = "", description: str = "", model: str = None) -> list:
    """
    Uses OpenRouter AI to analyze video transcript, title, and channel,
    producing 8 high-relevance search queries engineered to rank the video
    in the top 1 to 5 YouTube search results.
    """
    clean_title = (title or "").strip()
    if not clean_title and not video_id:
        return ["trending youtube video"]

    transcript = extract_youtube_transcript(video_id)

    # Try OpenRouter AI generation
    try:
        system_prompt = (
            "You are a world-class YouTube SEO search ranking specialist. "
            "Your task is to generate 8 search phrases that a real user can type into YouTube search "
            "to reliably find and rank this specific target video on the first page (top 1-5 results). "
            "Respond ONLY with a valid JSON array containing exactly 8 strings."
        )

        user_prompt = f"""
Target Video Details:
- Video ID: {video_id}
- Title: {clean_title}
- Creator/Channel: {channel}
- Description Excerpt: {description[:400] if description else "N/A"}
- Transcript Excerpt: {transcript[:2500] if transcript else "Transcript unavailable"}

Instructions:
1. Generate EXACTLY 8 distinct, highly specific search queries.
2. Include:
   - Creator name + core subject/tutorial topic
   - Exact title variant or key subject phrase
   - Distinct phrases/terminology mentioned in transcript
   - How-to / Tutorial phrasing matching the video subject
   - Catchy keyword combo unique to this video
3. Ensure each phrase will immediately find this video in the top 2-5 YouTube search results.
4. Output STRICT JSON format: ["phrase 1", "phrase 2", "phrase 3", "phrase 4", "phrase 5", "phrase 6", "phrase 7", "phrase 8"]
"""

        ai_response = call_openrouter(
            prompt=user_prompt,
            model=model,
            system_prompt=system_prompt,
        )

        # Parse JSON from AI response (strip code block markers if present)
        clean_json = re.sub(r'^```(json)?\s*', '', ai_response.strip(), flags=re.IGNORECASE)
        clean_json = re.sub(r'\s*```$', '', clean_json.strip())
        import json as pyjson
        parsed = pyjson.loads(clean_json)

        if isinstance(parsed, list) and len(parsed) >= 4:
            clean_list = [str(k).strip() for k in parsed if str(k).strip()]
            if clean_list:
                return clean_list[:8]
    except Exception as e:
        logger.info("OpenRouter AI keyword generation fallback (%s), using deterministic generator.", e)

    # Fallback to deterministic generator
    return generate_smart_keywords(title=clean_title, channel=channel)


def generate_smart_keywords(title: str, channel: str = "") -> list:
    """
    Deterministic fallback generating 8 high-precision categorized search queries.
    """
    clean_title = (title or "").strip()
    if not clean_title:
        return [f"{channel} video".strip()] if channel else ["trending youtube video"]

    title_words = [w for w in re.sub(r'[^\w\s]', '', clean_title).split() if len(w) > 2]
    core_topic = " ".join(title_words[:4]) if title_words else clean_title

    queries = []
    # 1. Exact Creator + Topic
    if channel:
        queries.append(f"{channel} {core_topic}".strip())
    # 2. Exact Title
    queries.append(clean_title)
    # 3. Topic + Channel
    if channel:
        queries.append(f"{core_topic} {channel}".strip())
    # 4. Specific Tooling / Topic
    if len(title_words) >= 2:
        queries.append(f"{title_words[0]} {core_topic}".strip())
    # 5. Hook / Thumbnail catchphrase
    if len(title_words) >= 3:
        queries.append(" ".join(title_words[:3]))
    # 6. Educational search
    queries.append(f"how to {core_topic} {channel}".strip())
    # 7. Case study / Complete guide
    queries.append(f"{core_topic} complete guide {channel}".strip())
    # 8. Best tutorial
    queries.append(f"best {core_topic} tutorial {channel}".strip())

    # De-duplicate while preserving order
    seen = set()
    unique_queries = []
    for q in queries:
        cleaned = " ".join(q.split())
        if cleaned.lower() not in seen and len(cleaned) > 2:
            seen.add(cleaned.lower())
            unique_queries.append(cleaned)

    return unique_queries[:8]


def generate_randomized_instruction(task, user=None) -> dict:
    """
    Generates a personalized randomized search instruction for the user
    based on the task's keyword search phrases and title.
    """
    keywords = [str(k).strip() for k in task.keywords] if isinstance(task.keywords, list) else []
    if not keywords and task.search_keywords:
        keywords = [k.strip() for k in task.search_keywords.split(',') if k.strip()]
    keywords = [k for k in keywords if k]
    title = (task.title or "").strip()
    
    seed_val = f"{user.id if user and hasattr(user, 'id') else 0}_{task.id}_{random.randint(1, 1000)}"
    rng = random.Random(seed_val)

    if keywords:
        search_query = rng.choice(keywords)
    elif title:
        search_query = title
    else:
        search_query = "trending videos"

    instruction_text = (
        f"1. Tap 'Start Task' to open YouTube.\n"
        f"2. Search on YouTube for: \"{search_query}\"\n"
        f"3. Locate and tap the video matching the task thumbnail shown on your task card.\n"
        f"4. Watch the video to automatically accumulate rewards!"
    )

    vid = getattr(task, 'video_id', '') or extract_youtube_video_id(task.source_url)
    thumb = task.thumbnail_url or (f"https://i.ytimg.com/vi/{vid}/hqdefault.jpg" if vid else "")

    return {
        'search_query': search_query,
        'full_instruction': instruction_text,
        'title': title,
        'thumbnail_url': thumb,
    }


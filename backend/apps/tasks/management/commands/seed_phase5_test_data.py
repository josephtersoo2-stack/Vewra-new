import uuid
from decimal import Decimal
from django.core.management.base import BaseCommand
from django.utils import timezone
from apps.tasks.models import (
    Task,
    TaskType,
    TaskStatus,
    QuizQuestion,
    QuizQuestionType,
)

class Command(BaseCommand):
    help = "Seeds development video tasks and verification quiz questions for Phase 5 testing."

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE("Seeding Phase 5 test tasks and quizzes..."))

        # Task 1: Flutter Ecosystem Overview (Short 30s watch time for testing)
        task1, created1 = Task.objects.update_or_create(
            slug="flutter-cross-platform-architecture",
            defaults={
                "title": "Flutter 3.x Cross-Platform Architecture",
                "task_type": TaskType.VIDEO,
                "status": TaskStatus.ACTIVE,
                "description": "Explore the multi-platform rendering architecture of Flutter, Impeller graphics engine, and reactive UI paradigms.",
                "instructions": [
                    "Watch the short technical overview video.",
                    "Keep the browser window active during playback.",
                    "Complete the 1-question verification quiz after reaching 100% watch progress.",
                    "Claim your verified 25 Coins reward!"
                ],
                "thumbnail_url": "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600&auto=format&fit=crop&q=80",
                "source_url": "https://www.youtube.com/watch?v=fq4N0hgOWzU",
                "source_platform": "YouTube",
                "channel_name": "Flutter Dev Team",
                "search_keywords": "flutter dart cross-platform rendering mobile",
                "reward_coins": 25,
                "reward_cash": Decimal("0.25"),
                "reward_xp": 50,
                "required_watch_seconds": 30,  # Short duration for fast dev/testing verification
                "quiz_required": True,
                "quiz_pass_percentage": 70,
                "daily_user_limit": 5,
                "minimum_level": 1,
                "minimum_trust_score": 50,
                "verification_required": False,
            }
        )

        # Quiz Question for Task 1
        QuizQuestion.objects.update_or_create(
            task=task1,
            question_text="What is the primary graphics rendering engine introduced in modern Flutter on Android & iOS?",
            defaults={
                "question_type": QuizQuestionType.MULTIPLE_CHOICE,
                "options": ["Skia Classic", "Impeller", "DirectX 9", "Flash Player"],
                "correct_answer": "Impeller",
                "explanation": "Impeller is Flutter's dedicated rendering engine designed to eliminate shader compilation jank.",
                "difficulty": "EASY",
                "active": True,
                "source_timestamp_seconds": 15,
            }
        )

        # Task 2: PostgreSQL 16 ACID Transactions & High Concurrency (15s watch time, no quiz)
        task2, created2 = Task.objects.update_or_create(
            slug="postgresql-acid-transactions-ledger",
            defaults={
                "title": "PostgreSQL 16 ACID Transactions & Financial Ledgers",
                "task_type": TaskType.VIDEO,
                "status": TaskStatus.ACTIVE,
                "description": "Learn how double-entry financial accounting and row-level locking prevent race conditions in modern Web3/FinTech apps.",
                "instructions": [
                    "Watch the 15-second intro segment.",
                    "Heartbeats verify real-time playback.",
                    "Instantly receive your 15 Coins upon video completion."
                ],
                "thumbnail_url": "https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=600&auto=format&fit=crop&q=80",
                "source_url": "https://www.youtube.com/watch?v=7S_tz1z_5bA",
                "source_platform": "YouTube",
                "channel_name": "Database Internals",
                "search_keywords": "postgresql database sql transactions ledger",
                "reward_coins": 15,
                "reward_cash": Decimal("0.15"),
                "reward_xp": 30,
                "required_watch_seconds": 15,  # Super fast test task
                "quiz_required": False,
                "daily_user_limit": 10,
                "minimum_level": 1,
                "minimum_trust_score": 40,
                "verification_required": False,
            }
        )

        # Task 3: Advanced KYC & Trust Score Safety (Locked task requiring Level 3 for eligibility testing)
        task3, created3 = Task.objects.update_or_create(
            slug="advanced-identity-trust-verification",
            defaults={
                "title": "VIP Masterclass: Advanced Digital Identity & Trust Score Safety",
                "task_type": TaskType.VIDEO,
                "status": TaskStatus.ACTIVE,
                "description": "Exclusive high-reward training session for Verified level users on multi-tier security and fraud prevention.",
                "instructions": [
                    "Requires Level 3 and Verified KYC tier.",
                    "Watch the full 60-second video.",
                    "Pass the verification quiz to claim 100 Coins."
                ],
                "thumbnail_url": "https://images.unsplash.com/photo-1563986768609-322da13575f3?w=600&auto=format&fit=crop&q=80",
                "source_url": "https://www.youtube.com/watch?v=l4Tf4G5i2yA",
                "source_platform": "YouTube",
                "channel_name": "VEWRA Security Lab",
                "search_keywords": "security kyc trust identity vip",
                "reward_coins": 100,
                "reward_cash": Decimal("1.00"),
                "reward_xp": 200,
                "required_watch_seconds": 60,
                "quiz_required": True,
                "quiz_pass_percentage": 100,
                "daily_user_limit": 1,
                "minimum_level": 3,  # Level 3 gate for eligibility testing
                "minimum_trust_score": 75,
                "verification_required": True,
            }
        )

        QuizQuestion.objects.update_or_create(
            task=task3,
            question_text="Which trust tier grants priority payout processing and maximum daily task limits?",
            defaults={
                "question_type": QuizQuestionType.MULTIPLE_CHOICE,
                "options": ["Basic", "Unverified", "Trusted VIP", "Guest"],
                "correct_answer": "Trusted VIP",
                "explanation": "Trusted VIP tier is the highest tier of trust in the VEWRA ecosystem.",
                "difficulty": "MEDIUM",
                "active": True,
            }
        )

        self.stdout.write(
            self.style.SUCCESS(
                f"Successfully seeded tasks:\n"
                f" - {task1.title} (Quiz required: {task1.quiz_required})\n"
                f" - {task2.title} (Quiz required: {task2.quiz_required})\n"
                f" - {task3.title} (Level 3 Gate: {task3.minimum_level})"
            )
        )

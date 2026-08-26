import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/tasks/models/task_model.dart';
import 'package:vewra_mobile/features/tasks/models/task_attempt_model.dart';
import 'package:vewra_mobile/features/tasks/models/task_eligibility_model.dart';
import 'package:vewra_mobile/features/tasks/models/quiz_question_model.dart';
import 'package:vewra_mobile/features/tasks/models/quiz_result_model.dart';

void main() {
  group('TaskModel Tests', () {
    test('fromJson deserializes backend fields correctly', () {
      final json = {
        'id': 'task-123',
        'title': 'Test Video Task',
        'slug': 'test-video-task',
        'task_type': 'VIDEO',
        'status': 'ACTIVE',
        'description': 'Watch and verify this test video.',
        'instructions': ['Rule 1', 'Rule 2'],
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'source_url': 'https://youtube.com/watch?v=123',
        'source_platform': 'YouTube',
        'channel_name': 'Tech Channel',
        'reward_coins': 50,
        'reward_cash': '0.50',
        'reward_xp': 30,
        'required_watch_seconds': 120,
        'quiz_required': true,
        'quiz_pass_percentage': 80,
        'minimum_level': 2,
        'minimum_trust_score': 60,
        'verification_required': true,
        'is_completed': false,
      };

      final model = TaskModel.fromJson(json);
      expect(model.id, 'task-123');
      expect(model.title, 'Test Video Task');
      expect(model.rewardCoins, 50);
      expect(model.rewardCash, 0.50);
      expect(model.rewardFiat, 0.50);
      expect(model.requiredWatchSeconds, 120);
      expect(model.durationMinutes, 2);
      expect(model.quizRequired, isTrue);
      expect(model.quizPassPercentage, 80);
      expect(model.instructions.length, 2);
    });
  });

  group('TaskAttemptModel Tests', () {
    test('fromJson deserializes attempt correctly', () {
      final json = {
        'id': 'attempt-456',
        'task_id': 'task-123',
        'task_title': 'Test Video Task',
        'task_thumbnail': 'https://example.com/thumb.jpg',
        'reward_coins': 50,
        'status': 'COMPLETED',
        'started_at': '2026-08-26T12:00:00Z',
        'completed_at': '2026-08-26T12:05:00Z',
        'reward_granted': true,
        'reward_reference': 'TASK-attempt-456',
        'quiz_required': false,
        'quiz_passed': null,
        'quiz_score': null,
        'failure_reason': '',
      };

      final model = TaskAttemptModel.fromJson(json);
      expect(model.id, 'attempt-456');
      expect(model.isCompleted, isTrue);
      expect(model.rewardGranted, isTrue);
      expect(model.rewardReference, 'TASK-attempt-456');
    });
  });

  group('TaskEligibilityModel Tests', () {
    test('fromJson parses requirements breakdown', () {
      final json = {
        'eligible': false,
        'reasons': ['Minimum Trust Score 60 required (Current: 45)'],
        'requirements': {
          'account_active': true,
          'task_active': true,
          'schedule': true,
          'capacity': true,
          'level': true,
          'trust_score': false,
          'verification': true,
          'daily_limit': true,
          'repeat_rule': true,
        },
        'active_attempt_id': null,
      };

      final model = TaskEligibilityModel.fromJson(json);
      expect(model.eligible, isFalse);
      expect(model.reasons.length, 1);
      expect(model.requirements.trustScore, isFalse);
      expect(model.requirements.level, isTrue);
    });
  });

  group('Quiz Models Tests', () {
    test('QuizQuestionModel does not include correct answer in public model', () {
      final json = {
        'id': 'q-1',
        'question_text': 'What was discussed?',
        'question_type': 'MULTIPLE_CHOICE',
        'options': ['Option A', 'Option B', 'Option C'],
        'source_timestamp_seconds': 45,
        'difficulty': 'EASY',
      };

      final question = QuizQuestionModel.fromJson(json);
      expect(question.id, 'q-1');
      expect(question.options.length, 3);
      expect(question.sourceTimestampSeconds, 45);
    });

    test('QuizResultModel parses outcome correctly', () {
      final json = {
        'attempt_id': 'attempt-456',
        'score': 100.0,
        'pass_percentage': 70,
        'passed': true,
        'total_questions': 2,
        'correct_answers': 2,
      };

      final result = QuizResultModel.fromJson(json);
      expect(result.passed, isTrue);
      expect(result.score, 100.0);
      expect(result.correctAnswers, 2);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/browser/models/watch_session_model.dart';
import 'package:vewra_mobile/features/browser/models/watch_progress_model.dart';
import 'package:vewra_mobile/features/browser/models/watch_completion_model.dart';

void main() {
  group('Tracking Models Tests', () {
    test('WatchSessionModel parses session payload correctly', () {
      final json = {
        'id': 'sess-123',
        'attempt_id': 'attempt-456',
        'task_id': 'task-789',
        'status': 'ACTIVE',
        'required_seconds': 60,
        'credited_watch_seconds': 30,
        'progress_percentage': 50.0,
        'is_satisfied': false,
        'source_url': 'https://youtube.com/watch?v=123',
        'channel_name': 'Creator Studio',
        'last_sequence': 3,
        'watch_token': 'secret-watch-token-urlsafe',
        'quiz_required': true,
      };

      final session = WatchSessionModel.fromJson(json);
      expect(session.id, 'sess-123');
      expect(session.attemptId, 'attempt-456');
      expect(session.creditedWatchSeconds, 30);
      expect(session.watchToken, 'secret-watch-token-urlsafe');
      expect(session.quizRequired, isTrue);
    });

    test('WatchProgressModel deserializes heartbeat progress', () {
      final json = {
        'id': 'sess-123',
        'state': 'ACTIVE',
        'credited_watch_seconds': 45,
        'required_seconds': 60,
        'progress_percentage': 75.0,
        'quiz_required': false,
        'is_satisfied': false,
      };

      final progress = WatchProgressModel.fromJson(json);
      expect(progress.creditedWatchSeconds, 45);
      expect(progress.progressPercentage, 75.0);
      expect(progress.isSatisfied, isFalse);
    });

    test('WatchCompletionModel parses completed reward grant', () {
      final json = {
        'status': 'COMPLETED',
        'message': 'Reward granted successfully.',
        'reward': {
          'coins': 25,
          'cash': '0.25',
          'xp': 15,
          'reference': 'TASK-attempt-456',
        },
        'attempt_id': 'attempt-456',
      };

      final completion = WatchCompletionModel.fromJson(json);
      expect(completion.isCompleted, isTrue);
      expect(completion.rewardCoins, 25);
      expect(completion.rewardReference, 'TASK-attempt-456');
    });

    test('WatchCompletionModel parses awaiting quiz status', () {
      final json = {
        'status': 'AWAITING_QUIZ',
        'message': 'Watch time verified. Please complete the quiz to claim your reward.',
        'attempt_id': 'attempt-456',
      };

      final completion = WatchCompletionModel.fromJson(json);
      expect(completion.isAwaitingQuiz, isTrue);
      expect(completion.isCompleted, isFalse);
    });
  });
}

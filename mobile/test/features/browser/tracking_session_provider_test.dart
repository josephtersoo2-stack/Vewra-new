import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/features/browser/data/tracking_repository.dart';
import 'package:vewra_mobile/features/browser/models/watch_session_model.dart';
import 'package:vewra_mobile/features/browser/models/watch_progress_model.dart';
import 'package:vewra_mobile/features/browser/models/watch_completion_model.dart';
import 'package:vewra_mobile/features/browser/providers/tracking_session_provider.dart';

class MockTrackingRepository extends TrackingRepository {
  @override
  Future<WatchProgressModel> sendHeartbeat({
    required String sessionId,
    required String watchToken,
    required int sequence,
    double? playbackPosition,
    DateTime? clientTimestamp,
  }) async {
    return WatchProgressModel(
      id: sessionId,
      state: 'ACTIVE',
      creditedWatchSeconds: 30,
      requiredSeconds: 60,
      progressPercentage: 50.0,
      isSatisfied: false,
    );
  }

  @override
  Future<WatchCompletionModel> verifyCompletion({
    required String sessionId,
    required String watchToken,
  }) async {
    return const WatchCompletionModel(
      status: 'COMPLETED',
      message: 'Verified successfully',
      rewardCoins: 20,
      rewardCash: '0.20',
      rewardXp: 15,
      rewardReference: 'TASK-attempt-1',
    );
  }

  @override
  Future<Map<String, dynamic>> sendEvent({
    required String sessionId,
    required String watchToken,
    required String eventType,
    required int sequence,
    double? playbackPosition,
    Map<String, dynamic>? metadata,
  }) async {
    return {'status': 'recorded'};
  }
}

void main() {
  group('TrackingSessionProvider Tests', () {
    test('initializes session and handles heartbeats', () async {
      final container = ProviderContainer(
        overrides: [
          trackingRepositoryProvider.overrideWithValue(MockTrackingRepository()),
        ],
      );

      addTearDown(container.dispose);

      const session = WatchSessionModel(
        id: 'sess-100',
        attemptId: 'att-100',
        taskId: 'task-100',
        status: 'ACTIVE',
        requiredSeconds: 60,
        creditedWatchSeconds: 0,
        progressPercentage: 0.0,
        watchToken: 'test-token',
      );

      final notifier = container.read(trackingSessionProvider.notifier);
      notifier.initializeSession(session: session, watchToken: 'test-token');

      var state = container.read(trackingSessionProvider);
      expect(state.isActive, isTrue);
      expect(state.watchToken, 'test-token');

      // Send heartbeat
      await notifier.sendHeartbeat();
      state = container.read(trackingSessionProvider);
      expect(state.creditedWatchSeconds, 30);
      expect(state.progressPercentage, 50.0);
      expect(state.sequence, 2);

      // Verify completion
      final result = await notifier.verifyCompletion();
      expect(result?.isCompleted, isTrue);
      expect(result?.rewardCoins, 20);

      state = container.read(trackingSessionProvider);
      expect(state.isCompleted, isTrue);
    });
  });
}

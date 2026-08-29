import '../models/watch_session_model.dart';
import '../models/watch_progress_model.dart';
import '../models/watch_completion_model.dart';
import 'tracking_api_service.dart';

class TrackingRepository {
  final TrackingApiService _apiService;

  TrackingRepository({TrackingApiService? apiService})
      : _apiService = apiService ?? TrackingApiService();

  Future<WatchSessionModel> getSession(String sessionId) =>
      _apiService.getSession(sessionId);

  Future<WatchProgressModel> sendHeartbeat({
    required String sessionId,
    required String watchToken,
    required int sequence,
    double? playbackPosition,
    DateTime? clientTimestamp,
    bool isGoogleAuthenticated = true,
  }) =>
      _apiService.sendHeartbeat(
        sessionId: sessionId,
        watchToken: watchToken,
        sequence: sequence,
        playbackPosition: playbackPosition,
        clientTimestamp: clientTimestamp,
        isGoogleAuthenticated: isGoogleAuthenticated,
      );

  Future<Map<String, dynamic>> sendEvent({
    required String sessionId,
    required String watchToken,
    required String eventType,
    required int sequence,
    double? playbackPosition,
    Map<String, dynamic>? metadata,
  }) =>
      _apiService.sendEvent(
        sessionId: sessionId,
        watchToken: watchToken,
        eventType: eventType,
        sequence: sequence,
        playbackPosition: playbackPosition,
        metadata: metadata,
      );

  Future<WatchCompletionModel> verifyCompletion({
    required String sessionId,
    required String watchToken,
  }) =>
      _apiService.verifyCompletion(
        sessionId: sessionId,
        watchToken: watchToken,
      );

  Future<void> abandonSession({
    required String sessionId,
    required String watchToken,
  }) =>
      _apiService.abandonSession(
        sessionId: sessionId,
        watchToken: watchToken,
      );
}

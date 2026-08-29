import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/watch_session_model.dart';
import '../models/watch_progress_model.dart';
import '../models/watch_completion_model.dart';

class TrackingApiService {
  final ApiClient _apiClient;

  TrackingApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches current server tracking state for a session.
  Future<WatchSessionModel> getSession(String sessionId) async {
    final response =
        await _apiClient.dio.get(ApiConstants.trackingSession(sessionId));
    if (response.statusCode == 200 && response.data != null) {
      return WatchSessionModel.fromJson(
          response.data['session'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load tracking session.');
  }

  /// Sends periodic watch heartbeat ping with sequence number and secure watch token.
  Future<WatchProgressModel> sendHeartbeat({
    required String sessionId,
    required String watchToken,
    required int sequence,
    double? playbackPosition,
    DateTime? clientTimestamp,
    bool isGoogleAuthenticated = true,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConstants.trackingHeartbeat(sessionId),
      data: {
        'sequence': sequence,
        'is_google_authenticated': isGoogleAuthenticated,
        if (playbackPosition != null) 'playback_position': playbackPosition,
        if (clientTimestamp != null)
          'client_timestamp': clientTimestamp.toIso8601String(),
      },
      options: Options(
        headers: {'X-VEWRA-WATCH-TOKEN': watchToken},
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final sessionData = response.data['session'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return WatchProgressModel.fromJson(sessionData);
    }
    throw Exception(response.data?['message'] ?? 'Failed to send heartbeat.');
  }

  /// Sends player/lifecycle event to the backend.
  Future<Map<String, dynamic>> sendEvent({
    required String sessionId,
    required String watchToken,
    required String eventType,
    required int sequence,
    double? playbackPosition,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConstants.trackingEvents(sessionId),
      data: {
        'event_type': eventType,
        'sequence': sequence,
        if (playbackPosition != null) 'playback_position': playbackPosition,
        if (metadata != null) 'metadata': metadata,
      },
      options: Options(
        headers: {'X-VEWRA-WATCH-TOKEN': watchToken},
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception(response.data?['message'] ?? 'Failed to record event.');
  }

  /// Requests server-authoritative completion verification and reward grant.
  Future<WatchCompletionModel> verifyCompletion({
    required String sessionId,
    required String watchToken,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConstants.trackingComplete(sessionId),
      options: Options(
        headers: {'X-VEWRA-WATCH-TOKEN': watchToken},
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return WatchCompletionModel.fromJson(
          response.data as Map<String, dynamic>);
    }
    throw Exception(
        response.data?['message'] ?? 'Failed to verify task completion.');
  }

  /// Abandons the active session.
  Future<void> abandonSession({
    required String sessionId,
    required String watchToken,
  }) async {
    await _apiClient.dio.post(
      ApiConstants.trackingAbandon(sessionId),
      options: Options(
        headers: {'X-VEWRA-WATCH-TOKEN': watchToken},
      ),
    );
  }
}

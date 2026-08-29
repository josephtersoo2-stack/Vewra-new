import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/task_model.dart';
import '../models/task_attempt_model.dart';
import '../models/task_eligibility_model.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_result_model.dart';
import '../../browser/models/watch_session_model.dart';

class TaskApiService {
  final ApiClient _apiClient;

  TaskApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches available tasks from the backend catalogue.
  Future<List<TaskModel>> getTasks({String? type, String? search}) async {
    final queryParams = <String, dynamic>{};
    if (type != null && type.isNotEmpty && type != 'ALL') {
      queryParams['type'] = type;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiClient.dio.get(
      ApiConstants.tasks,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final list = response.data['tasks'] as List<dynamic>? ?? [];
      return list
          .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetches full details and eligibility for a specific task.
  Future<Map<String, dynamic>> getTaskDetails(String id) async {
    final response = await _apiClient.dio.get(ApiConstants.taskDetails(id));
    if (response.statusCode == 200 && response.data != null) {
      final task = TaskModel.fromJson(
          response.data['task'] as Map<String, dynamic>);
      final eligibility = TaskEligibilityModel.fromJson(
          response.data['eligibility'] as Map<String, dynamic>);
      return {'task': task, 'eligibility': eligibility};
    }
    throw Exception('Failed to load task details.');
  }

  /// Checks server-authoritative eligibility for a task.
  Future<TaskEligibilityModel> checkEligibility(String id) async {
    final response = await _apiClient.dio.get(ApiConstants.taskEligibility(id));
    if (response.statusCode == 200 && response.data != null) {
      return TaskEligibilityModel.fromJson(
          response.data['eligibility'] as Map<String, dynamic>);
    }
    throw Exception('Failed to evaluate task eligibility.');
  }

  /// Initiates a task attempt and returns the provisioned attempt and watch session.
  Future<Map<String, dynamic>> startTask(
    String id, {
    String clientPlatform = 'MOBILE',
    String appVersion = '1.0.0',
  }) async {
    final response = await _apiClient.dio.post(
      ApiConstants.taskStart(id),
      data: {
        'client_platform': clientPlatform,
        'app_version': appVersion,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final attempt = TaskAttemptModel.fromJson(
          response.data['attempt'] as Map<String, dynamic>);
      final watchSession = WatchSessionModel.fromJson(
          response.data['watch_session'] as Map<String, dynamic>);
      return {
        'attempt': attempt,
        'watch_session': watchSession,
      };
    }
    throw Exception(response.data?['message'] ?? 'Failed to start task.');
  }

  /// Fetches user's task attempts.
  Future<List<TaskAttemptModel>> getAttempts() async {
    final response = await _apiClient.dio.get(ApiConstants.taskAttempts);
    if (response.statusCode == 200 && response.data != null) {
      final list = response.data['attempts'] as List<dynamic>? ?? [];
      return list
          .map((item) =>
              TaskAttemptModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetches quiz questions for an attempt once watch requirement is satisfied.
  Future<List<QuizQuestionModel>> getQuiz(String attemptId) async {
    final response =
        await _apiClient.dio.get(ApiConstants.taskQuiz(attemptId));
    if (response.statusCode == 200 && response.data != null) {
      final list = response.data['questions'] as List<dynamic>? ?? [];
      return list
          .map((item) =>
              QuizQuestionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response.data?['message'] ?? 'Failed to fetch quiz.');
  }

  /// Submits answers to the quiz endpoint.
  Future<QuizResultModel> submitQuiz(
    String attemptId,
    List<Map<String, String>> answers,
  ) async {
    final response = await _apiClient.dio.post(
      ApiConstants.taskQuizSubmit(attemptId),
      data: {'answers': answers},
    );

    if (response.statusCode == 200 && response.data != null) {
      return QuizResultModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception(response.data?['message'] ?? 'Failed to submit quiz.');
  }

  /// Fetches metadata and generated keywords for a YouTube URL.
  Future<Map<String, dynamic>> fetchYouTubeMeta(String youtubeUrl) async {
    final response = await _apiClient.dio.post(
      ApiConstants.taskFetchMeta,
      data: {'youtube_url': youtubeUrl},
    );
    if (response.statusCode == 200 && response.data != null) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception(response.data?['message'] ?? 'Failed to fetch YouTube metadata.');
  }

  /// Creates and publishes a new video task.
  Future<TaskModel> createVideoTask({
    required String sourceUrl,
    required String title,
    required String channelName,
    required String thumbnailUrl,
    required String rewardType,
    required int rewardCoins,
    required int rewardXp,
    required int requiredWatchSeconds,
    required List<String> keywords,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConstants.taskCreate,
      data: {
        'source_url': sourceUrl,
        'title': title,
        'channel_name': channelName,
        'thumbnail_url': thumbnailUrl,
        'reward_type': rewardType,
        'reward_coins': rewardCoins,
        'reward_xp': rewardXp,
        'required_watch_seconds': requiredWatchSeconds,
        'keywords': keywords,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return TaskModel.fromJson(response.data['task'] as Map<String, dynamic>);
    }
    throw Exception(response.data?['message'] ?? 'Failed to create task.');
  }
}


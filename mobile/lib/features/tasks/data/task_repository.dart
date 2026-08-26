import '../models/task_model.dart';
import '../models/task_attempt_model.dart';
import '../models/task_eligibility_model.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_result_model.dart';
import 'task_api_service.dart';

class TaskRepository {
  final TaskApiService _apiService;

  TaskRepository({TaskApiService? apiService})
      : _apiService = apiService ?? TaskApiService();

  Future<List<TaskModel>> getTasks({String? type, String? search}) =>
      _apiService.getTasks(type: type, search: search);

  Future<Map<String, dynamic>> getTaskDetails(String id) =>
      _apiService.getTaskDetails(id);

  Future<TaskEligibilityModel> checkEligibility(String id) =>
      _apiService.checkEligibility(id);

  Future<Map<String, dynamic>> startTask(String id) =>
      _apiService.startTask(id);

  Future<List<TaskAttemptModel>> getAttempts() =>
      _apiService.getAttempts();

  Future<List<QuizQuestionModel>> getQuiz(String attemptId) =>
      _apiService.getQuiz(attemptId);

  Future<QuizResultModel> submitQuiz(
          String attemptId, List<Map<String, String>> answers) =>
      _apiService.submitQuiz(attemptId, answers);
}

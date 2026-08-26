import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/task_repository.dart';
import '../models/task_model.dart';
import '../models/task_eligibility_model.dart';
import 'task_feed_provider.dart';

class TaskDetailsState {
  final bool isLoading;
  final TaskModel? task;
  final TaskEligibilityModel? eligibility;
  final String? errorMessage;

  const TaskDetailsState({
    this.isLoading = false,
    this.task,
    this.eligibility,
    this.errorMessage,
  });

  TaskDetailsState copyWith({
    bool? isLoading,
    TaskModel? task,
    TaskEligibilityModel? eligibility,
    String? errorMessage,
  }) {
    return TaskDetailsState(
      isLoading: isLoading ?? this.isLoading,
      task: task ?? this.task,
      eligibility: eligibility ?? this.eligibility,
      errorMessage: errorMessage,
    );
  }
}

class TaskDetailsNotifier extends StateNotifier<TaskDetailsState> {
  final TaskRepository _repository;
  final String _taskId;

  TaskDetailsNotifier(this._repository, this._taskId)
      : super(const TaskDetailsState(isLoading: true)) {
    loadDetails();
  }

  Future<void> loadDetails() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _repository.getTaskDetails(_taskId);
      state = TaskDetailsState(
        isLoading: false,
        task: data['task'] as TaskModel?,
        eligibility: data['eligibility'] as TaskEligibilityModel?,
      );
    } catch (e) {
      state = TaskDetailsState(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() => loadDetails();
}

final taskDetailsProvider = StateNotifierProvider.family<TaskDetailsNotifier,
    TaskDetailsState, String>((ref, taskId) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskDetailsNotifier(repo, taskId);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/task_repository.dart';
import '../models/task_model.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final taskCategoryFilterProvider = StateProvider<String>((ref) => 'ALL');
final taskSearchQueryProvider = StateProvider<String>((ref) => '');

/// State model for task feed
class TaskFeedState {
  final bool isLoading;
  final List<TaskModel> tasks;
  final String? errorMessage;

  const TaskFeedState({
    this.isLoading = false,
    this.tasks = const [],
    this.errorMessage,
  });

  TaskFeedState copyWith({
    bool? isLoading,
    List<TaskModel>? tasks,
    String? errorMessage,
  }) {
    return TaskFeedState(
      isLoading: isLoading ?? this.isLoading,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage,
    );
  }
}

class TaskFeedNotifier extends StateNotifier<TaskFeedState> {
  final TaskRepository _repository;
  final Ref _ref;

  TaskFeedNotifier(this._repository, this._ref)
      : super(const TaskFeedState(isLoading: true)) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final filter = _ref.read(taskCategoryFilterProvider);
      final search = _ref.read(taskSearchQueryProvider);
      final tasks = await _repository.getTasks(
        type: filter == 'ALL' ? null : filter,
        search: search.isEmpty ? null : search,
      );
      state = TaskFeedState(isLoading: false, tasks: tasks);
    } catch (e) {
      state = TaskFeedState(
        isLoading: false,
        tasks: state.tasks,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() => loadTasks();
}

final taskFeedProvider =
    StateNotifierProvider<TaskFeedNotifier, TaskFeedState>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskFeedNotifier(repo, ref);
});

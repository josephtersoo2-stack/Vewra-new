import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/features/tasks/data/task_repository.dart';
import 'package:vewra_mobile/features/tasks/models/task_model.dart';
import 'package:vewra_mobile/features/tasks/providers/task_feed_provider.dart';

class MockTaskRepository extends TaskRepository {
  final List<TaskModel> mockTasks;
  MockTaskRepository(this.mockTasks);

  @override
  Future<List<TaskModel>> getTasks({String? type, String? search}) async {
    return mockTasks;
  }
}

void main() {
  group('TaskFeedProvider Tests', () {
    test('loads tasks into state successfully', () async {
      final sampleTasks = [
        const TaskModel(
          id: '1',
          title: 'First Task',
          rewardCoins: 20,
        ),
        const TaskModel(
          id: '2',
          title: 'Second Task',
          rewardCoins: 40,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider
              .overrideWithValue(MockTaskRepository(sampleTasks)),
        ],
      );

      addTearDown(container.dispose);

      // Initial trigger
      final notifier = container.read(taskFeedProvider.notifier);
      await notifier.loadTasks();

      final state = container.read(taskFeedProvider);
      expect(state.isLoading, isFalse);
      expect(state.tasks.length, 2);
      expect(state.tasks.first.title, 'First Task');
    });
  });
}

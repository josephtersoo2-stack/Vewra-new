import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/features/home/screens/home_screen.dart';
import 'package:vewra_mobile/features/tasks/data/task_repository.dart';
import 'package:vewra_mobile/features/tasks/models/task_model.dart';
import 'package:vewra_mobile/features/tasks/providers/task_feed_provider.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

class _FakeTaskRepository extends TaskRepository {
  @override
  Future<List<TaskModel>> getTasks({String? type, String? search}) async => [];
}

void main() {
  testWidgets('HomeScreen renders user greeting, ad spot banner, level progress, ecosystem shortcuts, and task lists', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(_FakeTaskRepository()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('${AppStrings.greeting},'), findsOneWidget);
    expect(find.text(DummyDataService.currentUser.username), findsOneWidget);
    expect(find.text('SPONSORED'), findsOneWidget);
    expect(find.text('LVL ${DummyDataService.currentUser.level}'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text(AppStrings.dailyGoal), findsOneWidget);
    expect(find.text(AppStrings.featuredTasks), findsOneWidget);
    expect(find.text(AppStrings.recommendedTasks), findsOneWidget);
  });
}

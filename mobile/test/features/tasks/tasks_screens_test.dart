import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/features/tasks/screens/tasks_screen.dart';
import 'package:vewra_mobile/features/tasks/screens/task_details_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  group('Tasks Screens Tests', () {
    testWidgets('TasksScreen renders search bar, category chips, and task list', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TasksScreen(),
          ),
        ),
      );

      expect(find.text(AppStrings.tasks), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Tech'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Gaming'), findsOneWidget);

      // Tap category chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'Tech'));
      await tester.pump();
      expect(find.text(DummyDataService.tasks.first.title), findsOneWidget);
    });

    testWidgets('TaskDetailsScreen renders task title, instructions, and start button', (WidgetTester tester) async {
      final sampleTask = DummyDataService.tasks.first;

      await tester.pumpWidget(
        MaterialApp(
          home: TaskDetailsScreen(task: sampleTask),
        ),
      );

      expect(find.text(AppStrings.taskDetails), findsOneWidget);
      expect(find.text(sampleTask.title), findsOneWidget);
      expect(find.text(sampleTask.channelName), findsOneWidget);
      expect(find.text(AppStrings.searchInstructions), findsOneWidget);
      expect(find.text(sampleTask.searchKeywords), findsOneWidget);
      expect(find.byKey(const Key('start_watching_button')), findsOneWidget);
    });
  });
}

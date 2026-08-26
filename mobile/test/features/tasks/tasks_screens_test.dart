import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/features/tasks/screens/tasks_screen.dart';
import 'package:vewra_mobile/features/tasks/screens/task_details_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  group('Tasks Screens Tests', () {
    testWidgets('TasksScreen renders search bar, category chips, and search input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TasksScreen(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Earn & Tasks'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Video Tasks'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Surveys'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Social Tasks'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Challenges'), findsOneWidget);
    });

    testWidgets('TaskDetailsScreen renders task title, instructions, and start button', (WidgetTester tester) async {
      final sampleTask = DummyDataService.tasks.first;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskDetailsScreen(task: sampleTask),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text(AppStrings.taskDetails), findsOneWidget);
      expect(find.text(sampleTask.title), findsOneWidget);
      expect(find.text(sampleTask.channelName), findsOneWidget);
      expect(find.text(AppStrings.searchInstructions), findsOneWidget);
      expect(find.text(sampleTask.searchKeywords), findsOneWidget);
      expect(find.byKey(const Key('start_watching_button')), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/features/tasks/screens/tasks_screen.dart';
import 'package:vewra_mobile/features/tasks/screens/task_details_screen.dart';
import 'package:vewra_mobile/features/tasks/models/task_model.dart';

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

    testWidgets('TaskDetailsScreen renders thumbnail preview, keyword copy card, and start button', (WidgetTester tester) async {
      const sampleTask = TaskModel(
        id: 'test_task_1',
        title: 'Top 10 Flutter Features',
        channelName: 'TechVanguard',
        description: 'Explore new Flutter UI widgets.',
        thumbnailUrl: '',
        youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        searchKeywords: 'Flutter 3.22 features tutorial',
        rewardCoins: 120,
        rewardFiat: 1.20,
        durationMinutes: 4,
        category: 'Video Tasks',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskDetailsScreen(task: sampleTask),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text(AppStrings.taskDetails), findsOneWidget);
      expect(find.text('YouTube Video Task'), findsOneWidget);
      expect(find.text('Assigned Search Keyword'), findsOneWidget);
      expect(find.text(sampleTask.searchKeywords), findsOneWidget);
      expect(find.byKey(const Key('start_watching_button')), findsOneWidget);
    });
  });
}

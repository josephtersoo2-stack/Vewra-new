import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/features/browser/screens/browser_screen.dart';
import 'package:vewra_mobile/features/tasks/models/task_model.dart';

void main() {
  testWidgets('BrowserScreen renders top bar, search copy button, and simulator controls in test environment',
      (WidgetTester tester) async {
    const sampleTask = TaskModel(
      id: 'test_task_1',
      title: 'Top 10 Flutter 3.22 Features',
      channelName: 'TechVanguard',
      description: 'Explore new Flutter UI widgets and compiler optimizations.',
      thumbnailUrl: '',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      searchKeywords: 'Flutter 3.22 features deep dive tutorial 2026',
      rewardCoins: 120,
      rewardFiat: 1.20,
      durationMinutes: 4,
      category: 'Video Tasks',
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: BrowserScreen(task: sampleTask, isTestMode: true),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byIcon(CupertinoIcons.doc_on_doc), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.refresh), findsOneWidget);
    expect(find.text(sampleTask.title), findsOneWidget);
  });
}

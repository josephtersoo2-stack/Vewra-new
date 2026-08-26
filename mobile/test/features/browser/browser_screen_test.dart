import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/features/browser/screens/browser_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  testWidgets('BrowserScreen renders top bar, tracking HUD, player area, and verify button', (WidgetTester tester) async {
    final sampleTask = DummyDataService.tasks.first;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: BrowserScreen(task: sampleTask),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(sampleTask.sourceUrl), findsOneWidget);
    expect(find.text(sampleTask.title), findsOneWidget);
    expect(find.byKey(const Key('verify_task_button')), findsOneWidget);
    expect(find.text('Resume Playback'), findsOneWidget);

    // Tap resume playback to switch to active
    await tester.tap(find.text('Resume Playback'));
    await tester.pump();
    expect(find.text('Pause Playback'), findsOneWidget);
  });
}

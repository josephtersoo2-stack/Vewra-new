import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/features/browser/screens/browser_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  testWidgets('BrowserScreen renders top bar, tracking HUD, WebView slot, and control buttons', (WidgetTester tester) async {
    final sampleTask = DummyDataService.tasks.first;

    await tester.pumpWidget(
      MaterialApp(
        home: BrowserScreen(task: sampleTask),
      ),
    );

    expect(find.text(sampleTask.youtubeUrl), findsOneWidget);
    expect(find.text('Tracking Active'), findsOneWidget);
    expect(find.text(AppStrings.pauseTracking), findsOneWidget);
    expect(find.text(AppStrings.completeVerification), findsOneWidget);

    // Toggle pause tracking
    await tester.tap(find.text(AppStrings.pauseTracking));
    await tester.pump();
    expect(find.text(AppStrings.resumeTracking), findsOneWidget);
    expect(find.text('Tracking Paused'), findsOneWidget);

    // Open verification dialog
    await tester.tap(find.byKey(const Key('complete_verification_button')));
    await tester.pump();
    expect(find.text('Task Verified!'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/widgets/feedback/app_loading.dart';
import 'package:vewra_mobile/core/widgets/feedback/app_empty_state.dart';
import 'package:vewra_mobile/core/widgets/feedback/app_error_state.dart';

void main() {
  group('Feedback Widgets Tests', () {
    testWidgets('AppLoading renders spinner and message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoading(message: 'Loading tasks...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading tasks...'), findsOneWidget);
    });

    testWidgets('AppEmptyState renders icon, title, description, and triggers action', (WidgetTester tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              icon: Icons.inbox_rounded,
              title: 'Empty List',
              description: 'Nothing here yet.',
              actionText: 'Refresh',
              onAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Empty List'), findsOneWidget);
      expect(find.text('Nothing here yet.'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);

      await tester.tap(find.text('Refresh'));
      expect(actionTriggered, isTrue);
    });

    testWidgets('AppErrorState renders error message and retry button', (WidgetTester tester) async {
      bool retryTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorState(
              title: 'Connection Error',
              message: 'Server unreachable',
              onRetry: () => retryTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Connection Error'), findsOneWidget);
      expect(find.text('Server unreachable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retryTriggered, isTrue);
    });
  });
}

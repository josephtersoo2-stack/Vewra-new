import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/widgets/layout/app_drawer.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  group('AppDrawer Tests', () {
    testWidgets('AppDrawer renders user summary, ecosystem modules, and triggers callbacks', (WidgetTester tester) async {
      int? navigatedTab;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              onNavigateTab: (index) => navigatedTab = index,
            ),
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                child: const Text('Open Drawer'),
              ),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Verify User Summary in Header
      expect(find.text(DummyDataService.currentUser.username), findsOneWidget);
      expect(find.text(DummyDataService.currentUser.email), findsOneWidget);
      expect(find.text('LVL ${DummyDataService.currentUser.level}'), findsOneWidget);
      expect(find.text('Trust: ${DummyDataService.currentUser.trustScore}%'), findsOneWidget);

      // Verify Ecosystem Navigation Items in view
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Level & Achievements'), findsOneWidget);
      expect(find.text('Verification'), findsOneWidget);

      // Tap Level & Achievements item (navigates to Rewards tab index 2)
      await tester.tap(find.text('Level & Achievements'));
      await tester.pumpAndSettle();
      expect(navigatedTab, equals(2));
    });

    testWidgets('AppDrawer opens modal bottom sheet for placeholder ecosystem features', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: const AppDrawer(),
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                child: const Text('Open Drawer'),
              ),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Find and scroll to Coin Exchange
      await tester.scrollUntilVisible(
        find.text('Coin Exchange'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tap Coin Exchange
      await tester.tap(find.text('Coin Exchange'));
      await tester.pumpAndSettle();

      expect(find.text('P2P Coin Exchange'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
      expect(find.text('P2P Coin Exchange'), findsNothing);
    });
  });
}

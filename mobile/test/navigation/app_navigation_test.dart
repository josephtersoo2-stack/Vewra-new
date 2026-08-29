import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/main.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/core/routing/app_routes.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

import 'package:vewra_mobile/features/shell/main_shell.dart';
import 'package:vewra_mobile/features/tasks/data/task_repository.dart';
import 'package:vewra_mobile/features/tasks/models/task_model.dart';
import 'package:vewra_mobile/features/tasks/providers/task_feed_provider.dart';

class _FakeTaskRepository extends TaskRepository {
  @override
  Future<List<TaskModel>> getTasks({String? type, String? search}) async => [];
}

void main() {
  group('App Navigation Flow Tests', () {
    testWidgets('Initial launch loads splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: VewraApp(initialRoute: AppRoutes.splash)));
      await tester.pump();
      expect(find.text(AppStrings.appName), findsOneWidget);
    });

    testWidgets('Direct route to /welcome loads welcome screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: VewraApp(initialRoute: AppRoutes.welcome)));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
    });

    testWidgets('Direct route to /login loads login screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: VewraApp(initialRoute: AppRoutes.login)));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('Direct route to /register loads register screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: VewraApp(initialRoute: AppRoutes.register)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('register_username_field')), findsOneWidget);
      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
    });

    testWidgets('Direct route to /marketplace loads marketplace screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: VewraApp(initialRoute: AppRoutes.marketplace)));
      await tester.pumpAndSettle();
      expect(find.text('Digital Marketplace'), findsOneWidget);
    });

    testWidgets('Direct route to /community loads community screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: VewraApp(initialRoute: AppRoutes.community)));
      await tester.pumpAndSettle();
      expect(find.text('VEWRA Community Hub'), findsOneWidget);
    });

    testWidgets('Direct route to /verification loads verification screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: VewraApp(initialRoute: AppRoutes.verification)));
      await tester.pumpAndSettle();
      expect(find.text('Identity & Trust Score'), findsOneWidget);
    });

    testWidgets('Direct route to /main loads shell and allows switching all 5 tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(_FakeTaskRepository()),
          ],
          child: const MaterialApp(
            home: MainShell(initialIndex: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Initially on Home Tab (index 0)
      expect(find.text('${AppStrings.greeting},'), findsOneWidget);
      expect(find.text(AppStrings.featuredTasks), findsOneWidget);

      // 2. Switch to Earn Tab (index 1)
      await tester.tap(find.byKey(const Key('nav_tab_1')), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Earn & Tasks'), findsOneWidget);

      // 3. Switch to Rewards Tab (index 2)
      await tester.tap(find.byKey(const Key('nav_tab_2')), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Rewards & XP Hub'), findsOneWidget);

      // 4. Switch to Wallet Tab (index 3)
      await tester.tap(find.byKey(const Key('nav_tab_3')), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Buy Coins'), findsOneWidget);

      // 5. Switch to Profile Tab (index 4)
      await tester.tap(find.byKey(const Key('nav_tab_4')), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text(DummyDataService.currentUser.email), findsOneWidget);
    });
  });
}

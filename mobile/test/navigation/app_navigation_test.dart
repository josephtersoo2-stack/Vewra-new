import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/main.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/core/routing/app_routes.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  group('App Navigation Flow Tests', () {
    testWidgets('Initial launch loads splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.splash));
      await tester.pump();
      expect(find.text(AppStrings.appName), findsOneWidget);
    });

    testWidgets('Direct route to /welcome loads welcome screen', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.welcome));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
    });

    testWidgets('Direct route to /login loads login screen', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.login));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('Direct route to /register loads register screen', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.register));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('register_username_field')), findsOneWidget);
      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
    });

    testWidgets('Direct route to /marketplace loads marketplace screen', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.marketplace));
      await tester.pumpAndSettle();
      expect(find.text('Digital Marketplace'), findsOneWidget);
    });

    testWidgets('Direct route to /community loads community screen', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.community));
      await tester.pumpAndSettle();
      expect(find.text('VEWRA Community Hub'), findsOneWidget);
    });

    testWidgets('Direct route to /verification loads verification screen', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.verification));
      await tester.pumpAndSettle();
      expect(find.text('Identity & Trust Score'), findsOneWidget);
    });

    testWidgets('Direct route to /main loads shell and allows switching all 5 tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.mainShell));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 1. Initially on Home Tab (index 0)
      expect(find.text('${AppStrings.greeting},'), findsOneWidget);
      expect(find.text(AppStrings.featuredTasks), findsOneWidget);

      // 2. Switch to Earn Tab (index 1)
      await tester.tap(find.byKey(const Key('nav_tab_1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Earn & Tasks'), findsOneWidget);

      // 3. Switch to Rewards Tab (index 2)
      await tester.tap(find.byKey(const Key('nav_tab_2')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Rewards & XP Hub'), findsOneWidget);

      // 4. Switch to Wallet Tab (index 3)
      await tester.tap(find.byKey(const Key('nav_tab_3')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Buy Coins'), findsOneWidget);

      // 5. Switch to Profile Tab (index 4)
      await tester.tap(find.byKey(const Key('nav_tab_4')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(DummyDataService.currentUser.email), findsOneWidget);
    });
  });
}

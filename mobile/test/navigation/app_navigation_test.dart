import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/main.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/core/routing/app_routes.dart';

void main() {
  group('App Navigation Flow Tests', () {
    testWidgets('Initial launch loads splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.splash));
      expect(find.text(AppStrings.appName), findsOneWidget);
    });

    testWidgets('Direct route to /welcome loads welcome screen', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.welcome));
      expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
    });

    testWidgets('Direct route to /login loads login screen', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.login));
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('Direct route to /register loads register screen', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.register));
      expect(find.byKey(const Key('register_username_field')), findsOneWidget);
      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
    });

    testWidgets('Direct route to /main loads shell and allows tab switching', (WidgetTester tester) async {
      await tester.pumpWidget(const VewraApp(initialRoute: AppRoutes.mainShell));

      // Initially on Home Tab
      expect(find.text('${AppStrings.greeting},'), findsOneWidget);
      expect(find.text(AppStrings.featuredTasks), findsOneWidget);

      // Switch to Tasks Tab (icon: Icons.play_circle_outline_rounded)
      await tester.tap(find.byIcon(Icons.play_circle_outline_rounded));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget); // search input on tasks screen

      // Switch to Wallet Tab (icon: Icons.account_balance_wallet_outlined)
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pump();
      expect(find.text(AppStrings.availableBalance), findsOneWidget);

      // Switch to Profile Tab (icon: Icons.person_outline_rounded)
      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pump();
      expect(find.text(AppStrings.editProfile), findsOneWidget);
    });
  });
}

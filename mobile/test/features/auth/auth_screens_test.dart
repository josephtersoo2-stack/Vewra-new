import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/features/auth/screens/welcome_screen.dart';
import 'package:vewra_mobile/features/auth/screens/login_screen.dart';
import 'package:vewra_mobile/features/auth/screens/register_screen.dart';
import 'package:vewra_mobile/features/auth/screens/forgot_password_screen.dart';

void main() {
  group('Auth Screens Tests', () {
    testWidgets('WelcomeScreen renders value propositions and action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
      expect(find.text(AppStrings.getStarted), findsOneWidget);
      expect(find.text(AppStrings.login), findsOneWidget);
    });

    testWidgets('LoginScreen renders inputs and validates empty submission', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);

      // Clear email and test validation
      await tester.enterText(find.byKey(const Key('login_email_field')), '');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      expect(find.text('Email address is required'), findsOneWidget);
    });

    testWidgets('RegisterScreen renders form fields and validates mismatching passwords', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      expect(find.byKey(const Key('register_username_field')), findsOneWidget);
      expect(find.byKey(const Key('register_email_field')), findsOneWidget);
      expect(find.byKey(const Key('register_password_field')), findsOneWidget);
      expect(find.byKey(const Key('register_confirm_password_field')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('register_username_field')), 'vewra_tester');
      await tester.enterText(find.byKey(const Key('register_email_field')), 'test@vewra.io');
      await tester.enterText(find.byKey(const Key('register_password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), 'differentpass');

      await tester.ensureVisible(find.byKey(const Key('register_submit_button')));
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen allows entering email and displays recovery message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      );

      expect(find.text(AppStrings.forgotPasswordTitle), findsOneWidget);
      await tester.enterText(find.byKey(const Key('forgot_password_email_field')), 'user@vewra.io');
      await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text(AppStrings.resetLinkSent), findsOneWidget);
    });
  });
}

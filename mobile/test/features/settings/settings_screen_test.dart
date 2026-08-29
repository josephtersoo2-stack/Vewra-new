import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/features/settings/screens/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen renders sections, preference switches, and logout button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.settings), findsOneWidget);
    expect(find.text(AppStrings.preferences.toUpperCase()), findsOneWidget);
    expect(find.text(AppStrings.pushNotifications), findsOneWidget);
    expect(find.text(AppStrings.soundEffects), findsOneWidget);
    expect(find.text(AppStrings.darkMode), findsOneWidget);
    expect(find.text(AppStrings.security.toUpperCase()), findsOneWidget);
    expect(find.text(AppStrings.biometricLogin), findsOneWidget);
    expect(find.text(AppStrings.legal.toUpperCase()), findsOneWidget);
    expect(find.text(AppStrings.termsOfService), findsOneWidget);
    expect(find.text(AppStrings.logout), findsOneWidget);

    // Toggle switch
    final switchFinder = find.byType(Switch).first;
    await tester.tap(switchFinder);
    await tester.pump();
  });
}

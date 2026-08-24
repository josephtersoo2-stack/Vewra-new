import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/features/splash/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders brand name, tagline, and loader', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(autoNavigate: false),
      ),
    );

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

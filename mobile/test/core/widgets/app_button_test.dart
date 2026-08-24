import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/widgets/buttons/app_button.dart';

void main() {
  testWidgets('AppButton renders text and triggers callback', (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: 'Click Me',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Click Me'), findsOneWidget);
    await tester.tap(find.text('Click Me'));
    expect(pressed, isTrue);
  });

  testWidgets('AppButton shows loading spinner when isLoading is true', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: 'Submit',
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

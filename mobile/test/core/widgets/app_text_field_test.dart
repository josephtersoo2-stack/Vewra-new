import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/widgets/inputs/app_text_field.dart';

void main() {
  testWidgets('AppTextField renders label, hint and accepts input', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            label: 'Test Label',
            hint: 'Test Hint',
            controller: controller,
          ),
        ),
      ),
    );

    expect(find.text('Test Label'), findsOneWidget);
    expect(find.text('Test Hint'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Hello VEWRA');
    expect(controller.text, 'Hello VEWRA');
  });

  testWidgets('AppTextField toggles password visibility', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTextField(
            label: 'Password',
            isPassword: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/widgets/cards/app_metric_card.dart';

void main() {
  testWidgets('AppMetricCard renders title, value, subtitle and responds to tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppMetricCard(
            title: 'Tasks Completed',
            value: '42',
            subtitle: '+12% this week',
            icon: Icons.task_alt_rounded,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Tasks Completed'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('+12% this week'), findsOneWidget);
    expect(find.byIcon(Icons.task_alt_rounded), findsOneWidget);

    await tester.tap(find.text('Tasks Completed'));
    expect(tapped, isTrue);
  });
}

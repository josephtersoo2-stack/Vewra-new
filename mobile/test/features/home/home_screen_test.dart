import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/features/home/screens/home_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  testWidgets('HomeScreen renders user greeting, wallet card, level progress, ecosystem shortcuts, and task lists', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeScreen(),
        ),
      ),
    );

    expect(find.text('${AppStrings.greeting},'), findsOneWidget);
    expect(find.text(DummyDataService.currentUser.username), findsOneWidget);
    expect(find.text(AppStrings.totalEarnings), findsOneWidget);
    expect(find.text('LVL ${DummyDataService.currentUser.level}'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text(AppStrings.dailyGoal), findsOneWidget);
    expect(find.text(AppStrings.featuredTasks), findsOneWidget);
    expect(find.text(AppStrings.recommendedTasks), findsOneWidget);
  });
}

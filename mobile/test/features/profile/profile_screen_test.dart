import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/features/profile/screens/profile_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  testWidgets('ProfileScreen renders user information, level progress, verification, subscription, and menu items', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileScreen(),
        ),
      ),
    );

    expect(find.text(AppStrings.profile), findsOneWidget);
    expect(find.text(DummyDataService.currentUser.username), findsOneWidget);
    expect(find.text(DummyDataService.currentUser.email), findsOneWidget);
    expect(find.text('LVL ${DummyDataService.currentUser.level}'), findsOneWidget);
    expect(find.text('Verification & Trust Score'), findsOneWidget);
    expect(find.text('Subscription Tier'), findsOneWidget);
    expect(find.text('Marketplace & Redemptions'), findsOneWidget);
    expect(find.text('Community & Discussions'), findsOneWidget);
    expect(find.text(AppStrings.paymentMethods), findsOneWidget);
    expect(find.text(AppStrings.referFriend), findsOneWidget);
    expect(find.text(AppStrings.settings), findsOneWidget);
    expect(find.text(AppStrings.logout), findsOneWidget);
  });
}

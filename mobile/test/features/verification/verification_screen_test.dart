import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/verification/screens/verification_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  testWidgets('VerificationScreen renders trust score, verification levels, and upgrade action', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VerificationScreen(),
      ),
    );

    expect(find.text('Identity & Trust Score'), findsOneWidget);
    expect(find.text('${DummyDataService.currentUser.trustScore}%'), findsOneWidget);
    expect(find.text('Trust Score: Excellent'), findsOneWidget);
    expect(find.text('Verification Levels & Privileges'), findsOneWidget);

    // Tiers
    expect(find.text('Basic User'), findsOneWidget);
    expect(find.text('Verified User'), findsOneWidget);
    expect(find.text('Trusted User'), findsOneWidget);

    // Scroll to and tap upgrade button on Trusted User
    final upgradeBtn = find.text('Upgrade to Trusted User');
    await tester.ensureVisible(upgradeBtn);
    await tester.pumpAndSettle();
    await tester.tap(upgradeBtn);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

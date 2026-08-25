import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/marketplace/screens/marketplace_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  testWidgets('MarketplaceScreen renders header, category filter chips, and item listings', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MarketplaceScreen(),
      ),
    );

    expect(find.text('Digital Marketplace'), findsOneWidget);
    expect(find.text('Spend & Trade Coins'), findsOneWidget);

    // Filter Chips (FilterChip widgets)
    expect(find.widgetWithText(FilterChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Airtime & Data'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Gift Cards'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Digital Products'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Coin Marketplace'), findsOneWidget);

    // Items
    expect(find.text(DummyDataService.marketplaceItems.first.title), findsOneWidget);

    // Filter interaction
    await tester.tap(find.widgetWithText(FilterChip, 'Gift Cards'));
    await tester.pump();
    expect(find.text('\$25 Amazon Digital Gift Card'), findsOneWidget);

    // Redeem button tap
    await tester.tap(find.text('Redeem').first);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';
import 'package:vewra_mobile/features/wallet/screens/wallet_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  testWidgets('WalletScreen renders balance card, action buttons, pending rewards, and transaction history', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: WalletScreen(),
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.wallet), findsOneWidget);
    expect(find.text(AppStrings.availableBalance), findsOneWidget);
    expect(find.text('Buy Coins'), findsOneWidget);
    expect(find.text('Sell Coins'), findsOneWidget);
    expect(find.text('Withdraw'), findsNWidgets(2));
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Pending Watch Rewards: ${DummyDataService.currentWallet.pendingCoins} Coins'), findsOneWidget);
    expect(find.text(AppStrings.transactionHistory), findsOneWidget);
    expect(find.text('View Ledger'), findsOneWidget);
    expect(find.text(DummyDataService.transactions.first.title), findsOneWidget);

    // Switch filter tab
    await tester.tap(find.text('Earnings'));
    await tester.pump();
    expect(find.text(DummyDataService.transactions.first.title), findsOneWidget);

    // Open Buy Coins modal
    await tester.tap(find.text('Buy Coins'));
    await tester.pump();
    expect(find.text('Buy VEWRA Coins'), findsOneWidget);
  });
}

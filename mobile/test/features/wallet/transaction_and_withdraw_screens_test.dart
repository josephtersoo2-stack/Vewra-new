import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/features/wallet/data/wallet_repository.dart';
import 'package:vewra_mobile/features/wallet/providers/wallet_provider.dart';
import 'package:vewra_mobile/features/wallet/screens/transaction_history_screen.dart';
import 'package:vewra_mobile/features/wallet/screens/withdraw_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';
import 'wallet_repository_test.dart';

void main() {
  group('Phase 4 Wallet Screens Tests', () {
    late MockWalletApiService mockApi;
    late WalletRepository repository;

    setUp(() {
      mockApi = MockWalletApiService();
      repository = WalletRepository(apiService: mockApi);
    });

    testWidgets('TransactionHistoryScreen renders filter tabs and transaction items', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: TransactionHistoryScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Transaction Ledger'), findsOneWidget);
      expect(find.text('All Activity'), findsOneWidget);
      expect(find.text('Rewards & Earnings'), findsOneWidget);
      expect(find.text('Payouts & Withdrawals'), findsOneWidget);
      expect(find.text('P2P Transfers'), findsOneWidget);

      expect(find.text(DummyDataService.transactions.first.title), findsOneWidget);

      // Tap filter
      await tester.tap(find.text('Payouts & Withdrawals'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('WithdrawScreen renders available balance, payout methods, and validates input', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: WithdrawScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Withdraw Funds'), findsOneWidget);
      expect(find.text('Available Balance'), findsOneWidget);
      expect(find.text('Select Payout Method'), findsOneWidget);
      expect(find.text('USDT (TRC-20 / BEP-20)'), findsOneWidget);
      expect(find.text('PayPal Account'), findsOneWidget);
      expect(find.text('Direct Bank Wire (SWIFT / IBAN)'), findsOneWidget);
      expect(find.text('Digital E-Gift Card (Amazon / Apple)'), findsOneWidget);
      expect(find.text('Confirm & Submit Payout'), findsOneWidget);

      // Tap 50% quick fill (50% of $34.50 = 17.25)
      await tester.tap(find.text('50%'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('17.25'), findsOneWidget);

      // Enter destination address
      await tester.enterText(find.byType(TextFormField).last, 'TXz999Address');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Submit payout
      await tester.tap(find.text('Confirm & Submit Payout'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify success snackbar
      expect(find.text('Withdrawal request submitted and queued for review!'), findsOneWidget);
    });
  });
}

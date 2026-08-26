import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/wallet/data/wallet_repository.dart';
import 'package:vewra_mobile/features/wallet/providers/wallet_provider.dart';
import 'wallet_repository_test.dart';

void main() {
  group('WalletNotifier Provider Tests', () {
    late WalletRepository repository;
    late MockWalletApiService mockApi;
    late WalletNotifier notifier;

    setUp(() {
      mockApi = MockWalletApiService();
      repository = WalletRepository(apiService: mockApi);
      notifier = WalletNotifier(repository);
    });

    test('loadWalletData populates wallet, transactions, and withdrawals in state', () async {
      await notifier.loadWalletData();
      expect(notifier.state.wallet.balanceCoins, 5000);
      expect(notifier.state.transactions.length, 1);
      expect(notifier.state.withdrawals.length, 1);
      expect(notifier.state.isLoading, false);
    });

    test('transferCoins updates state and adds successMessage', () async {
      await notifier.loadWalletData();
      final success = await notifier.transferCoins(
        recipientUsername: 'bob',
        amount: 1500,
        description: 'Tip',
      );
      expect(success, true);
      expect(notifier.state.wallet.balanceCoins, 3500);
      expect(notifier.state.successMessage, isNotNull);
    });

    test('submitWithdrawal updates state with new withdrawal', () async {
      await notifier.loadWalletData();
      final success = await notifier.submitWithdrawal(
        amount: 10.0,
        method: 'USDT',
        destination: 'TRX_TEST_ADDR',
      );
      expect(success, true);
      expect(notifier.state.withdrawals.length, 2);
      expect(notifier.state.wallet.balanceCoins, 4000);
      expect(notifier.state.successMessage, 'Withdrawal request submitted successfully.');
    });
  });
}

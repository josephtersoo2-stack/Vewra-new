import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/wallet/data/wallet_repository.dart';
import 'package:vewra_mobile/features/wallet/data/wallet_api_service.dart';
import 'package:vewra_mobile/models/wallet_model.dart';
import 'package:vewra_mobile/models/transaction_model.dart';
import 'package:vewra_mobile/features/wallet/models/withdrawal_model.dart';

class MockWalletApiService extends WalletApiService {
  WalletModel mockWallet = const WalletModel(
    balanceCoins: 5000,
    balanceFiat: 50.0,
    currency: 'USD',
  );

  List<TransactionModel> get mockTransactions => [
    TransactionModel(
      id: 'tx-1',
      title: 'Watch Task Reward',
      type: TransactionType.taskReward,
      amountCoins: 100,
      amountFiat: 1.0,
      timestamp: DateTime.now(),
    ),
  ];

  List<WithdrawalModel> get mockWithdrawals => [
    WithdrawalModel(
      id: 'wd-1',
      amount: 25.0,
      coinsDeducted: 2500,
      currency: 'USD',
      method: 'USDT',
      status: 'PENDING',
      destination: 'TRX123456789',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<WalletModel> fetchWalletBalance() async => mockWallet;

  @override
  Future<List<TransactionModel>> fetchCoinHistory({String? type}) async => mockTransactions;

  @override
  Future<List<WithdrawalModel>> fetchWithdrawals() async => List.from(mockWithdrawals);

  @override
  Future<Map<String, dynamic>> transferCoins({
    required String recipientUsername,
    required int amount,
    String description = '',
  }) async {
    mockWallet = mockWallet.copyWith(
      balanceCoins: mockWallet.balanceCoins - amount,
      balanceFiat: mockWallet.balanceFiat - (amount * 0.01),
    );
    return {
      'status': 'success',
      'message': 'Transferred successfully',
      'wallet': mockWallet.toJson(),
    };
  }

  @override
  Future<WithdrawalModel> createWithdrawal({
    required double amount,
    required String method,
    required String destination,
  }) async {
    final wd = WithdrawalModel(
      id: 'wd-new',
      amount: amount,
      coinsDeducted: (amount * 100).toInt(),
      currency: 'USD',
      method: method,
      status: 'PENDING',
      destination: destination,
      createdAt: DateTime.now(),
    );
    return wd;
  }
}

void main() {
  group('WalletRepository Unit Tests', () {
    late WalletRepository repository;
    late MockWalletApiService mockApi;

    setUp(() {
      mockApi = MockWalletApiService();
      repository = WalletRepository(apiService: mockApi);
    });

    test('fetchWallet caches and returns wallet data', () async {
      final wallet = await repository.fetchWallet();
      expect(wallet.balanceCoins, 5000);
      expect(wallet.balanceFiat, 50.0);
      expect(repository.cachedWallet?.balanceCoins, 5000);
    });

    test('fetchCoinTransactions returns list and caches', () async {
      final txs = await repository.fetchCoinTransactions();
      expect(txs.length, 1);
      expect(txs.first.title, 'Watch Task Reward');
    });

    test('transferCoins updates cached wallet and returns success', () async {
      await repository.fetchWallet();
      final res = await repository.transferCoins(
        recipientUsername: 'alice',
        amount: 1000,
        description: 'Gift',
      );
      expect(res['status'], 'success');
      expect(repository.cachedWallet?.balanceCoins, 4000);
    });

    test('submitWithdrawal deducts balance and appends withdrawal', () async {
      await repository.fetchWallet();
      await repository.fetchWithdrawals();
      final wd = await repository.submitWithdrawal(
        amount: 20.0,
        method: 'USDT',
        destination: 'TRX999',
      );
      expect(wd.amount, 20.0);
      expect(repository.cachedWithdrawals.length, 2);
      expect(repository.cachedWallet?.balanceCoins, 3000);
      expect(repository.cachedWallet?.balanceFiat, 30.0);
    });
  });
}

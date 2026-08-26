import '../../../services/dummy_data_service.dart';
import '../../../../models/wallet_model.dart';
import '../../../../models/transaction_model.dart';
import '../models/withdrawal_model.dart';
import 'wallet_api_service.dart';

class WalletRepository {
  final WalletApiService _apiService;
  WalletModel? _cachedWallet;
  List<TransactionModel> _cachedTransactions = [];
  List<WithdrawalModel> _cachedWithdrawals = [];

  WalletRepository({WalletApiService? apiService})
      : _apiService = apiService ?? WalletApiService();

  WalletModel? get cachedWallet => _cachedWallet;
  List<TransactionModel> get cachedTransactions => _cachedTransactions;
  List<WithdrawalModel> get cachedWithdrawals => _cachedWithdrawals;

  Future<WalletModel> fetchWallet({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedWallet != null) {
      return _cachedWallet!;
    }
    try {
      final wallet = await _apiService.fetchWalletBalance();
      _cachedWallet = wallet;
      return wallet;
    } catch (_) {
      _cachedWallet ??= DummyDataService.currentWallet;
      return _cachedWallet!;
    }
  }

  Future<List<TransactionModel>> fetchCoinTransactions({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedTransactions.isNotEmpty) {
      return _cachedTransactions;
    }
    try {
      final txs = await _apiService.fetchCoinHistory();
      if (txs.isNotEmpty) {
        _cachedTransactions = txs;
        return txs;
      }
    } catch (_) {}

    if (_cachedTransactions.isEmpty) {
      _cachedTransactions = DummyDataService.transactions;
    }
    return _cachedTransactions;
  }

  Future<Map<String, dynamic>> transferCoins({
    required String recipientUsername,
    required int amount,
    String description = '',
  }) async {
    final res = await _apiService.transferCoins(
      recipientUsername: recipientUsername,
      amount: amount,
      description: description,
    );
    if (res['wallet'] != null && res['wallet'] is Map<String, dynamic>) {
      _cachedWallet = WalletModel.fromJson(res['wallet'] as Map<String, dynamic>);
    }
    return res;
  }

  Future<List<WithdrawalModel>> fetchWithdrawals({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedWithdrawals.isNotEmpty) {
      return _cachedWithdrawals;
    }
    try {
      final list = await _apiService.fetchWithdrawals();
      _cachedWithdrawals = list;
      return list;
    } catch (_) {
      return _cachedWithdrawals;
    }
  }

  Future<WithdrawalModel> submitWithdrawal({
    required double amount,
    required String method,
    required String destination,
  }) async {
    final withdrawal = await _apiService.createWithdrawal(
      amount: amount,
      method: method,
      destination: destination,
    );
    _cachedWithdrawals.insert(0, withdrawal);
    if (_cachedWallet != null) {
      final coinsDeducted = (amount * 100).toInt();
      final newCoins = (_cachedWallet!.balanceCoins - coinsDeducted).clamp(0, double.infinity).toInt();
      final newCash = (_cachedWallet!.balanceFiat - amount).clamp(0.0, double.infinity);
      _cachedWallet = _cachedWallet!.copyWith(
        balanceCoins: newCoins,
        balanceFiat: newCash,
      );
    }
    return withdrawal;
  }

  void updateCachedWallet(WalletModel wallet) {
    _cachedWallet = wallet;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/dummy_data_service.dart';
import '../../../../models/wallet_model.dart';
import '../../../../models/transaction_model.dart';
import '../data/wallet_repository.dart';
import '../models/withdrawal_model.dart';

class WalletState {
  final WalletModel wallet;
  final List<TransactionModel> transactions;
  final List<WithdrawalModel> withdrawals;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const WalletState({
    required this.wallet,
    this.transactions = const [],
    this.withdrawals = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  WalletState copyWith({
    WalletModel? wallet,
    List<TransactionModel>? transactions,
    List<WithdrawalModel>? withdrawals,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearErrors = false,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      withdrawals: withdrawals ?? this.withdrawals,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearErrors ? null : (successMessage ?? this.successMessage),
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _repository;

  WalletNotifier(this._repository)
      : super(WalletState(
          wallet: _repository.cachedWallet ?? DummyDataService.currentWallet,
          transactions: _repository.cachedTransactions.isNotEmpty ? _repository.cachedTransactions : DummyDataService.transactions,
          withdrawals: _repository.cachedWithdrawals,
        ));

  Future<void> loadWalletData({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    try {
      final wallet = await _repository.fetchWallet(forceRefresh: forceRefresh);
      final txs = await _repository.fetchCoinTransactions(forceRefresh: forceRefresh);
      final withdrawals = await _repository.fetchWithdrawals(forceRefresh: forceRefresh);

      state = state.copyWith(
        wallet: wallet,
        transactions: txs,
        withdrawals: withdrawals,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to synchronize wallet balances.',
      );
    }
  }

  Future<bool> transferCoins({
    required String recipientUsername,
    required int amount,
    String description = '',
  }) async {
    state = state.copyWith(isSubmitting: true, clearErrors: true);
    try {
      final res = await _repository.transferCoins(
        recipientUsername: recipientUsername,
        amount: amount,
        description: description,
      );
      final updatedWallet = _repository.cachedWallet ?? state.wallet;
      final updatedTxs = await _repository.fetchCoinTransactions(forceRefresh: true);

      state = state.copyWith(
        wallet: updatedWallet,
        transactions: updatedTxs,
        isSubmitting: false,
        successMessage: res['message']?.toString() ?? 'Transfer completed successfully.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> submitWithdrawal({
    required double amount,
    required String method,
    required String destination,
  }) async {
    state = state.copyWith(isSubmitting: true, clearErrors: true);
    try {
      await _repository.submitWithdrawal(
        amount: amount,
        method: method,
        destination: destination,
      );
      final updatedWallet = _repository.cachedWallet ?? state.wallet;
      final updatedWithdrawals = _repository.cachedWithdrawals;
      final updatedTxs = await _repository.fetchCoinTransactions(forceRefresh: true);

      state = state.copyWith(
        wallet: updatedWallet,
        withdrawals: updatedWithdrawals,
        transactions: updatedTxs,
        isSubmitting: false,
        successMessage: 'Withdrawal request submitted successfully.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearErrors: true);
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return WalletNotifier(repository);
});

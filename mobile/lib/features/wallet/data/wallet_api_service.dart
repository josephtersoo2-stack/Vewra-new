import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../models/wallet_model.dart';
import '../../../../models/transaction_model.dart';
import '../models/withdrawal_model.dart';

class WalletApiService {
  final ApiClient _apiClient;

  WalletApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<WalletModel> fetchWalletBalance() async {
    final response = await _apiClient.get(ApiConstants.walletBalance);
    final data = response.data;
    if (data is Map<String, dynamic> && data['wallet'] != null) {
      return WalletModel.fromJson(data['wallet'] as Map<String, dynamic>);
    }
    return const WalletModel();
  }

  Future<List<TransactionModel>> fetchTransactions({String? type}) async {
    final queryParams = <String, dynamic>{};
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }
    final response = await _apiClient.get(
      ApiConstants.walletTransactions,
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['transactions'] is List) {
      return (data['transactions'] as List)
          .map((item) => TransactionModel.fromCashJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<TransactionModel>> fetchCoinHistory({String? type}) async {
    final queryParams = <String, dynamic>{};
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }
    final response = await _apiClient.get(
      ApiConstants.walletCoinsHistory,
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['coin_transactions'] is List) {
      return (data['coin_transactions'] as List)
          .map((item) => TransactionModel.fromCoinJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> transferCoins({
    required String recipientUsername,
    required int amount,
    String description = '',
  }) async {
    final response = await _apiClient.post(
      ApiConstants.walletCoinsTransfer,
      data: {
        'recipient_username': recipientUsername,
        'amount': amount,
        'description': description,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<WithdrawalModel>> fetchWithdrawals() async {
    final response = await _apiClient.get(ApiConstants.walletWithdrawals);
    final data = response.data;
    if (data is Map<String, dynamic> && data['withdrawals'] is List) {
      return (data['withdrawals'] as List)
          .map((item) => WithdrawalModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<WithdrawalModel> createWithdrawal({
    required double amount,
    required String method,
    required String destination,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.walletWithdrawalsCreate,
      data: {
        'amount': amount.toStringAsFixed(2),
        'method': method,
        'destination': destination,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['withdrawal'] != null) {
      return WithdrawalModel.fromJson(data['withdrawal'] as Map<String, dynamic>);
    }
    throw Exception('Failed to parse withdrawal response');
  }
}

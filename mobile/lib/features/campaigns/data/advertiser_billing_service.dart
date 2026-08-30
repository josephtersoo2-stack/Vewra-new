import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/campaign_billing_models.dart';

class AdvertiserBillingService {
  final ApiClient _apiClient;

  AdvertiserBillingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<AdvertiserWalletModel> getWallet() async {
    final response = await _apiClient.dio.get('${ApiConstants.baseUrl}/api/v1/advertiser/wallet/');

    if (response.statusCode == 200 && response.data != null) {
      return AdvertiserWalletModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load advertiser wallet.');
    }
  }

  Future<AdvertiserWalletModel> fundWallet(double amount, {String currency = 'USD'}) async {
    final response = await _apiClient.dio.post(
      '${ApiConstants.baseUrl}/api/v1/advertiser/wallet/fund/',
      data: {
        'amount': amount,
        'currency': currency,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return AdvertiserWalletModel.fromJson((data['wallet'] ?? data) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to deposit funds.');
    }
  }

  Future<CampaignSpendingModel> getCampaignSpending(String campaignId) async {
    final response = await _apiClient.dio.get(
      '${ApiConstants.campaigns}$campaignId/spending/',
    );

    if (response.statusCode == 200 && response.data != null) {
      return CampaignSpendingModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load campaign spending.');
    }
  }

  Future<List<BillingChargeModel>> getBillingHistory({String? campaignId, int limit = 50}) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (campaignId != null && campaignId.isNotEmpty) {
      queryParams['campaign_id'] = campaignId;
    }
    final response = await _apiClient.dio.get(
      '${ApiConstants.baseUrl}/api/v1/advertiser/billing/history/',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final list = (data['charges'] ?? data['results'] ?? []) as List<dynamic>;
      return list.map((c) => BillingChargeModel.fromJson(c as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load billing history.');
    }
  }

  Future<FinancialReportModel> getFinancialReport({String? campaignId}) async {
    final queryParams = <String, dynamic>{};
    if (campaignId != null && campaignId.isNotEmpty) {
      queryParams['campaign_id'] = campaignId;
    }
    final response = await _apiClient.dio.get(
      '${ApiConstants.baseUrl}/api/v1/advertiser/reports/',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      return FinancialReportModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to generate financial report.');
    }
  }
}

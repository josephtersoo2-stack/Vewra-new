import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/campaign_model.dart';

class CampaignApiService {
  final ApiClient _apiClient;

  CampaignApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches campaigns list with optional filters.
  Future<List<CampaignModel>> getCampaigns({
    String? status,
    String? type,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty && status != 'ALL') {
      queryParams['status'] = status;
    }
    if (type != null && type.isNotEmpty && type != 'ALL') {
      queryParams['type'] = type;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiClient.dio.get(
      ApiConstants.campaigns,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final list = (response.data['campaigns'] ?? response.data['results']) as List<dynamic>? ?? [];
      return list
          .map((item) => CampaignModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetches single campaign details.
  Future<CampaignModel> getCampaignDetails(String id) async {
    final response = await _apiClient.dio.get(ApiConstants.campaignDetails(id));
    if (response.statusCode == 200 && response.data != null) {
      final raw = response.data['campaign'] ?? response.data;
      return CampaignModel.fromJson(raw as Map<String, dynamic>);
    }
    throw Exception('Failed to load campaign details.');
  }

  /// Creates a new campaign in DRAFT status.
  Future<CampaignModel> createCampaign({
    required String title,
    required String campaignType,
    String description = '',
    double budget = 0.0,
    String? startDate,
    String? endDate,
  }) async {
    final payload = {
      'title': title,
      'campaign_type': campaignType,
      'description': description,
      'budget': budget,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    };

    final response = await _apiClient.dio.post(
      ApiConstants.campaignCreate,
      data: payload,
    );

    if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
      final raw = response.data['campaign'] ?? response.data;
      return CampaignModel.fromJson(raw as Map<String, dynamic>);
    }
    throw Exception('Failed to create campaign.');
  }

  /// Submits draft campaign for review.
  Future<CampaignModel> submitForReview(String id) async {
    final response = await _apiClient.dio.post(ApiConstants.campaignSubmit(id));
    if (response.statusCode == 200 && response.data != null) {
      final raw = response.data['campaign'] ?? response.data;
      return CampaignModel.fromJson(raw as Map<String, dynamic>);
    }
    throw Exception('Failed to submit campaign for review.');
  }

  /// Pauses an active campaign.
  Future<CampaignModel> pauseCampaign(String id) async {
    final response = await _apiClient.dio.post(ApiConstants.campaignPause(id));
    if (response.statusCode == 200 && response.data != null) {
      final raw = response.data['campaign'] ?? response.data;
      return CampaignModel.fromJson(raw as Map<String, dynamic>);
    }
    throw Exception('Failed to pause campaign.');
  }
}

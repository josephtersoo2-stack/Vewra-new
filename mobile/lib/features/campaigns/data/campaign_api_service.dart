import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/campaign_model.dart';
import '../models/ad_placement_model.dart';

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
      'start_date': ?startDate,
      'end_date': ?endDate,
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

  /// Phase 5.5 Step 3: Fetches active advertisements for a given placement surface (e.g. HOME_FEED, HEADER, POPUP).
  Future<List<AdPlacementModel>> getActiveAdsByLocation(
    String placementType, {
    int limit = 10,
  }) async {
    final response = await _apiClient.dio.get(
      ApiConstants.activeAdsByLocation(placementType),
      queryParameters: {'limit': limit},
    );

    if (response.statusCode == 200 && response.data != null) {
      final list = (response.data['ads'] ?? response.data['results']) as List<dynamic>? ?? [];
      return list
          .map((item) => AdPlacementModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetches placements for a specific campaign.
  Future<List<AdPlacementModel>> getCampaignPlacements(
    String campaignId, {
    String? status,
    String? type,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty && status != 'ALL') {
      queryParams['status'] = status;
    }
    if (type != null && type.isNotEmpty && type != 'ALL') {
      queryParams['type'] = type;
    }

    final response = await _apiClient.dio.get(
      ApiConstants.campaignPlacements(campaignId),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final list = (response.data['placements'] ?? response.data['results']) as List<dynamic>? ?? [];
      return list
          .map((item) => AdPlacementModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Creates a new advertisement placement.
  Future<AdPlacementModel> createCampaignPlacement(
    String campaignId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.dio.post(
      ApiConstants.campaignPlacements(campaignId),
      data: data,
    );

    if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
      final raw = response.data['placement'] ?? response.data;
      return AdPlacementModel.fromJson(raw as Map<String, dynamic>);
    }
    throw Exception('Failed to create advertisement placement.');
  }

  /// Updates an advertisement placement.
  Future<AdPlacementModel> updateCampaignPlacement(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.dio.patch(
      ApiConstants.adPlacementDetail(id),
      data: data,
    );

    if (response.statusCode == 200 && response.data != null) {
      final raw = response.data['placement'] ?? response.data;
      return AdPlacementModel.fromJson(raw as Map<String, dynamic>);
    }
    throw Exception('Failed to update advertisement placement.');
  }

  /// Soft-disables an advertisement placement.
  Future<AdPlacementModel> disableCampaignPlacement(String id) async {
    final response = await _apiClient.dio.delete(
      ApiConstants.adPlacementDetail(id),
    );

    if (response.statusCode == 200 && response.data != null) {
      final raw = response.data['placement'] ?? response.data;
      return AdPlacementModel.fromJson(raw as Map<String, dynamic>);
    }
    throw Exception('Failed to disable advertisement placement.');
  }

  /// Restores a disabled advertisement placement.
  Future<AdPlacementModel> restoreCampaignPlacement(String id) async {
    final response = await _apiClient.dio.post(
      ApiConstants.adPlacementRestore(id),
    );

    if (response.statusCode == 200 && response.data != null) {
      final raw = response.data['placement'] ?? response.data;
      return AdPlacementModel.fromJson(raw as Map<String, dynamic>);
    }
    throw Exception('Failed to restore advertisement placement.');
  }
}

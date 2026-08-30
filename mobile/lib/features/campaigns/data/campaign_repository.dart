import '../models/campaign_model.dart';
import '../models/ad_placement_model.dart';
import 'campaign_api_service.dart';

class CampaignRepository {
  final CampaignApiService _apiService;

  CampaignRepository({CampaignApiService? apiService})
      : _apiService = apiService ?? CampaignApiService();

  Future<List<CampaignModel>> getCampaigns({
    String? status,
    String? type,
    String? search,
  }) async {
    return await _apiService.getCampaigns(
      status: status,
      type: type,
      search: search,
    );
  }

  Future<CampaignModel> getCampaignDetails(String id) async {
    return await _apiService.getCampaignDetails(id);
  }

  Future<CampaignModel> createCampaign({
    required String title,
    required String campaignType,
    String description = '',
    double budget = 0.0,
    String? startDate,
    String? endDate,
  }) async {
    return await _apiService.createCampaign(
      title: title,
      campaignType: campaignType,
      description: description,
      budget: budget,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<CampaignModel> submitForReview(String id) async {
    return await _apiService.submitForReview(id);
  }

  Future<CampaignModel> pauseCampaign(String id) async {
    return await _apiService.pauseCampaign(id);
  }

  // Phase 5.5 Step 3: Advertisement Delivery & Placements
  Future<List<AdPlacementModel>> getActiveAdsByLocation(
    String placementType, {
    int limit = 10,
  }) async {
    return await _apiService.getActiveAdsByLocation(placementType, limit: limit);
  }

  Future<List<AdPlacementModel>> getCampaignPlacements(
    String campaignId, {
    String? status,
    String? type,
  }) async {
    return await _apiService.getCampaignPlacements(campaignId, status: status, type: type);
  }

  Future<AdPlacementModel> createCampaignPlacement(
    String campaignId,
    Map<String, dynamic> data,
  ) async {
    return await _apiService.createCampaignPlacement(campaignId, data);
  }

  Future<AdPlacementModel> updateCampaignPlacement(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _apiService.updateCampaignPlacement(id, data);
  }

  Future<AdPlacementModel> disableCampaignPlacement(String id) async {
    return await _apiService.disableCampaignPlacement(id);
  }

  Future<AdPlacementModel> restoreCampaignPlacement(String id) async {
    return await _apiService.restoreCampaignPlacement(id);
  }
}

import '../models/campaign_media_model.dart';
import 'campaign_media_api_service.dart';

class CampaignMediaRepository {
  final CampaignMediaApiService _apiService;

  CampaignMediaRepository({CampaignMediaApiService? apiService})
      : _apiService = apiService ?? CampaignMediaApiService();

  Future<List<CampaignMediaModel>> getMediaForCampaign(
    String campaignId, {
    String? mediaType,
    String? status,
  }) async {
    return _apiService.getCampaignMedia(
      campaignId,
      mediaType: mediaType,
      status: status,
    );
  }

  Future<CampaignMediaModel> uploadMedia({
    required String campaignId,
    required String filePath,
    required String fileName,
    required String mediaType,
    required String title,
    String description = '',
  }) async {
    return _apiService.uploadCampaignMedia(
      campaignId: campaignId,
      filePath: filePath,
      fileName: fileName,
      mediaType: mediaType,
      title: title,
      description: description,
    );
  }

  Future<CampaignMediaModel> updateMedia(
    String mediaId, {
    String? title,
    String? description,
    String? status,
  }) async {
    return _apiService.updateCampaignMedia(
      mediaId,
      title: title,
      description: description,
      status: status,
    );
  }

  Future<bool> disableMedia(String mediaId) async {
    return _apiService.disableCampaignMedia(mediaId);
  }

  Future<bool> restoreMedia(String mediaId) async {
    return _apiService.restoreCampaignMedia(mediaId);
  }
}

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/campaign_media_model.dart';

class CampaignMediaApiService {
  final ApiClient _apiClient;

  CampaignMediaApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<CampaignMediaModel>> getCampaignMedia(
    String campaignId, {
    String? mediaType,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (mediaType != null && mediaType != 'ALL') {
      queryParams['type'] = mediaType;
    }
    if (status != null && status != 'ALL') {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      ApiConstants.campaignMediaList(campaignId),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      final list = (data['media'] ?? data['results'] ?? []) as List;
      return list.map((item) => CampaignMediaModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch campaign media assets.');
  }

  Future<CampaignMediaModel> uploadCampaignMedia({
    required String campaignId,
    required String filePath,
    required String fileName,
    required String mediaType,
    required String title,
    String description = '',
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'media_type': mediaType,
      'title': title,
      'description': description,
    });

    final response = await _apiClient.dio.post(
      ApiConstants.campaignMediaUpload(campaignId),
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
      final mediaJson = response.data['media'] as Map<String, dynamic>;
      return CampaignMediaModel.fromJson(mediaJson);
    }
    throw Exception(response.data?['error']?.toString() ?? 'Failed to upload media asset.');
  }

  Future<CampaignMediaModel> updateCampaignMedia(
    String mediaId, {
    String? title,
    String? description,
    String? status,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status;

    final response = await _apiClient.patch(
      ApiConstants.campaignMediaDetail(mediaId),
      data: data,
    );

    if (response.statusCode == 200 && response.data != null) {
      final mediaJson = response.data['media'] as Map<String, dynamic>;
      return CampaignMediaModel.fromJson(mediaJson);
    }
    throw Exception('Failed to update media asset.');
  }

  Future<bool> disableCampaignMedia(String mediaId) async {
    final response = await _apiClient.delete(
      ApiConstants.campaignMediaDetail(mediaId),
    );
    return response.statusCode == 200 && (response.data?['success'] == true);
  }

  Future<bool> restoreCampaignMedia(String mediaId) async {
    final response = await _apiClient.post(
      ApiConstants.campaignMediaRestore(mediaId),
    );
    return response.statusCode == 200 && (response.data?['success'] == true);
  }
}

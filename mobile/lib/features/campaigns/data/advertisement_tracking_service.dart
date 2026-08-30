import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/campaign_analytics_model.dart';

class AdvertisementTrackingService {
  final ApiClient _apiClient;

  AdvertisementTrackingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Records an advertisement impression when a placement becomes visible to the user.
  Future<Map<String, dynamic>?> recordImpression({
    required String campaignId,
    required String placementId,
    required String mediaId,
    String? sessionId,
    String? deviceId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'campaign_id': campaignId,
        'placement_id': placementId,
        'media_id': mediaId,
      };
      if (sessionId != null && sessionId.isNotEmpty) {
        payload['session_id'] = sessionId;
      }
      if (deviceId != null && deviceId.isNotEmpty) {
        payload['device_id'] = deviceId;
      }

      final response = await _apiClient.dio.post(
        ApiConstants.adRecordImpression,
        data: payload,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('[AdTrackingService] Failed to record impression: $e');
    }
    return null;
  }

  /// Records an advertisement user interaction/click event.
  Future<Map<String, dynamic>?> recordClick({
    required String campaignId,
    required String mediaId,
    String? impressionId,
    String clickType = 'BANNER_CLICK',
    String? sessionId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'campaign_id': campaignId,
        'media_id': mediaId,
        'click_type': clickType,
      };
      if (impressionId != null && impressionId.isNotEmpty) {
        payload['impression_id'] = impressionId;
      }
      if (sessionId != null && sessionId.isNotEmpty) {
        payload['session_id'] = sessionId;
      }

      final response = await _apiClient.dio.post(
        ApiConstants.adRecordClick,
        data: payload,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('[AdTrackingService] Failed to record click: $e');
    }
    return null;
  }

  /// Records video playback watch progress and telemetry.
  Future<Map<String, dynamic>?> recordVideoProgress({
    required String campaignId,
    required String mediaId,
    required double watchedSeconds,
    String? sessionId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'campaign_id': campaignId,
        'media_id': mediaId,
        'watched_seconds': watchedSeconds,
      };
      if (sessionId != null && sessionId.isNotEmpty) {
        payload['session_id'] = sessionId;
      }

      final response = await _apiClient.dio.post(
        ApiConstants.adRecordVideoProgress,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('[AdTrackingService] Failed to record video progress: $e');
    }
    return null;
  }

  /// Fetches aggregated performance statistics for a specific campaign.
  Future<CampaignAnalyticsModel> getCampaignAnalytics(String campaignId) async {
    final response = await _apiClient.dio.get(
      ApiConstants.campaignAnalytics(campaignId),
    );

    if (response.statusCode == 200 && response.data != null) {
      return CampaignAnalyticsModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load campaign analytics.');
  }

  /// Fetches advertiser/platform overview performance metrics.
  Future<AdvertiserOverviewAnalyticsModel> getAdvertiserOverviewAnalytics() async {
    final response = await _apiClient.dio.get(
      ApiConstants.advertiserAnalyticsOverview,
    );

    if (response.statusCode == 200 && response.data != null) {
      return AdvertiserOverviewAnalyticsModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load advertiser overview analytics.');
  }
}

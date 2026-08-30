import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/advertisement_tracking_service.dart';
import '../models/campaign_analytics_model.dart';

final adTrackingServiceProvider = Provider<AdvertisementTrackingService>((ref) {
  return AdvertisementTrackingService();
});

final campaignAnalyticsProvider = FutureProvider.family<CampaignAnalyticsModel, String>((ref, campaignId) async {
  final service = ref.watch(adTrackingServiceProvider);
  return service.getCampaignAnalytics(campaignId);
});

final advertiserOverviewAnalyticsProvider = FutureProvider<AdvertiserOverviewAnalyticsModel>((ref) async {
  final service = ref.watch(adTrackingServiceProvider);
  return service.getAdvertiserOverviewAnalytics();
});

class AdTrackingState {
  final bool isRecording;
  final String? lastImpressionId;
  final String? lastClickId;
  final String? error;

  const AdTrackingState({
    this.isRecording = false,
    this.lastImpressionId,
    this.lastClickId,
    this.error,
  });

  AdTrackingState copyWith({
    bool? isRecording,
    String? lastImpressionId,
    String? lastClickId,
    String? error,
  }) {
    return AdTrackingState(
      isRecording: isRecording ?? this.isRecording,
      lastImpressionId: lastImpressionId ?? this.lastImpressionId,
      lastClickId: lastClickId ?? this.lastClickId,
      error: error,
    );
  }
}

class AdTrackingNotifier extends StateNotifier<AdTrackingState> {
  final AdvertisementTrackingService _service;

  AdTrackingNotifier(this._service) : super(const AdTrackingState());

  Future<String?> recordImpression({
    required String campaignId,
    required String placementId,
    required String mediaId,
    String? sessionId,
    String? deviceId,
  }) async {
    try {
      final res = await _service.recordImpression(
        campaignId: campaignId,
        placementId: placementId,
        mediaId: mediaId,
        sessionId: sessionId,
        deviceId: deviceId,
      );
      if (res != null && res['impression_id'] != null) {
        final impId = res['impression_id'].toString();
        state = state.copyWith(lastImpressionId: impId);
        return impId;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
    return null;
  }

  Future<String?> recordClick({
    required String campaignId,
    required String mediaId,
    String? impressionId,
    String clickType = 'BANNER_CLICK',
    String? sessionId,
  }) async {
    try {
      final res = await _service.recordClick(
        campaignId: campaignId,
        mediaId: mediaId,
        impressionId: impressionId ?? state.lastImpressionId,
        clickType: clickType,
        sessionId: sessionId,
      );
      if (res != null && res['click_id'] != null) {
        final clickId = res['click_id'].toString();
        state = state.copyWith(lastClickId: clickId);
        return clickId;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
    return null;
  }

  Future<void> recordVideoProgress({
    required String campaignId,
    required String mediaId,
    required double watchedSeconds,
    String? sessionId,
  }) async {
    try {
      await _service.recordVideoProgress(
        campaignId: campaignId,
        mediaId: mediaId,
        watchedSeconds: watchedSeconds,
        sessionId: sessionId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final adTrackingNotifierProvider = StateNotifierProvider<AdTrackingNotifier, AdTrackingState>((ref) {
  final service = ref.watch(adTrackingServiceProvider);
  return AdTrackingNotifier(service);
});

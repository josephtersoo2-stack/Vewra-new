import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/campaigns/models/campaign_analytics_model.dart';
import 'package:vewra_mobile/features/campaigns/providers/advertisement_tracking_provider.dart';
import 'package:vewra_mobile/features/campaigns/data/advertisement_tracking_service.dart';

class MockTrackingService extends AdvertisementTrackingService {
  bool impressionCalled = false;
  bool clickCalled = false;
  bool videoProgressCalled = false;

  @override
  Future<Map<String, dynamic>?> recordImpression({
    required String campaignId,
    required String placementId,
    required String mediaId,
    String? sessionId,
    String? deviceId,
  }) async {
    impressionCalled = true;
    return {'success': true, 'impression_id': 'mock-imp-123'};
  }

  @override
  Future<Map<String, dynamic>?> recordClick({
    required String campaignId,
    required String mediaId,
    String? impressionId,
    String clickType = 'BANNER_CLICK',
    String? sessionId,
  }) async {
    clickCalled = true;
    return {'success': true, 'click_id': 'mock-click-456'};
  }

  @override
  Future<Map<String, dynamic>?> recordVideoProgress({
    required String campaignId,
    required String mediaId,
    required double watchedSeconds,
    String? sessionId,
  }) async {
    videoProgressCalled = true;
    return {
      'success': true,
      'watched_seconds': watchedSeconds,
      'completion_percentage': 50.0,
      'completed': false,
    };
  }
}

void main() {
  group('Campaign Analytics Model Tests', () {
    test('parses CampaignAnalyticsModel from JSON successfully', () {
      final json = {
        'campaign_id': 'camp-001',
        'title': 'Spring Sale 2026',
        'status': 'ACTIVE',
        'total_impressions': 1500,
        'unique_viewers': 1200,
        'total_clicks': 150,
        'click_through_rate': 10.0,
        'clicks_by_type': {'BANNER_CLICK': 120, 'CALL_ACTION': 30},
        'creatives_performance': [
          {
            'media_id': 'media-1',
            'title': 'Creative Alpha',
            'media_type': 'IMAGE',
            'media_type_display': 'Image',
            'impressions': 1000,
            'clicks': 100,
            'ctr': 10.0,
          },
          {
            'media_id': 'media-2',
            'title': 'Video Promo',
            'media_type': 'VIDEO',
            'media_type_display': 'Video',
            'impressions': 500,
            'clicks': 50,
            'ctr': 10.0,
            'video_plays': 450,
            'completions': 380,
            'completion_rate': 84.4,
            'avg_watch_duration': 22.5,
          }
        ],
        'video_metrics': {
          'total_plays': 450,
          'completions': 380,
          'completion_rate': 84.4,
          'average_watch_duration': 22.5,
        },
        'timeline': [
          {'date': '2026-08-29', 'impressions': 800, 'clicks': 80},
          {'date': '2026-08-30', 'impressions': 700, 'clicks': 70},
        ],
      };

      final model = CampaignAnalyticsModel.fromJson(json);

      expect(model.campaignId, 'camp-001');
      expect(model.title, 'Spring Sale 2026');
      expect(model.totalImpressions, 1500);
      expect(model.uniqueViewers, 1200);
      expect(model.totalClicks, 150);
      expect(model.clickThroughRate, 10.0);
      expect(model.creativesPerformance.length, 2);
      expect(model.creativesPerformance[0].mediaId, 'media-1');
      expect(model.creativesPerformance[1].videoPlays, 450);
      expect(model.videoMetrics.totalPlays, 450);
      expect(model.videoMetrics.completionRate, 84.4);
      expect(model.timeline.length, 2);

      final backToJson = model.toJson();
      expect(backToJson['campaign_id'], 'camp-001');
      expect(backToJson['total_impressions'], 1500);
    });

    test('parses AdvertiserOverviewAnalyticsModel from JSON correctly', () {
      final json = {
        'total_campaigns': 5,
        'active_campaigns': 3,
        'total_impressions': 50000,
        'unique_viewers': 35000,
        'total_clicks': 2500,
        'overall_ctr': 5.0,
        'top_campaigns': [
          {'id': 'c1', 'title': 'Hero Promo', 'impressions': 30000}
        ],
      };

      final overview = AdvertiserOverviewAnalyticsModel.fromJson(json);
      expect(overview.totalCampaigns, 5);
      expect(overview.activeCampaigns, 3);
      expect(overview.totalImpressions, 50000);
      expect(overview.overallCtr, 5.0);
      expect(overview.topCampaigns.length, 1);
    });
  });

  group('AdTrackingNotifier State Tests', () {
    late MockTrackingService mockService;
    late AdTrackingNotifier notifier;

    setUp(() {
      mockService = MockTrackingService();
      notifier = AdTrackingNotifier(mockService);
    });

    test('records impression and updates lastImpressionId in state', () async {
      final impId = await notifier.recordImpression(
        campaignId: 'camp-100',
        placementId: 'place-200',
        mediaId: 'media-300',
      );

      expect(mockService.impressionCalled, isTrue);
      expect(impId, 'mock-imp-123');
      expect(notifier.state.lastImpressionId, 'mock-imp-123');
    });

    test('records click and updates lastClickId in state', () async {
      final clickId = await notifier.recordClick(
        campaignId: 'camp-100',
        mediaId: 'media-300',
        clickType: 'BANNER_CLICK',
      );

      expect(mockService.clickCalled, isTrue);
      expect(clickId, 'mock-click-456');
      expect(notifier.state.lastClickId, 'mock-click-456');
    });

    test('records video progress successfully', () async {
      await notifier.recordVideoProgress(
        campaignId: 'camp-100',
        mediaId: 'media-300',
        watchedSeconds: 15.0,
      );

      expect(mockService.videoProgressCalled, isTrue);
    });
  });
}

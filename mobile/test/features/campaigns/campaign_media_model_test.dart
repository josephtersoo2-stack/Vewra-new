import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/campaigns/models/campaign_media_model.dart';

void main() {
  group('CampaignMediaModel Tests', () {
    test('fromJson deserializes complete media payload accurately', () {
      final json = {
        'id': '7f8a9b0c-1d2e-3f4a-5b6c-7d8e9f0a1b2c',
        'campaign': 'c1d2e3f4-a5b6-7c8d-9e0f-1a2b3c4d5e6f',
        'media_type': 'BANNER',
        'media_type_display': 'Banner Asset',
        'file_url': 'http://127.0.0.1:8000/media/campaign_media/banner.png',
        'thumbnail_url': 'http://127.0.0.1:8000/media/campaign_media/thumb.png',
        'title': 'Homepage Leaderboard',
        'description': 'Main top banner creative',
        'file_size': 204800,
        'file_size_formatted': '200.0 KB',
        'mime_type': 'image/png',
        'duration_seconds': null,
        'width': 728,
        'height': 90,
        'status': 'READY',
        'status_display': 'Ready',
        'uploaded_by_email': 'advertiser@vewra.com',
        'created_at': '2026-08-29T22:00:00Z',
      };

      final model = CampaignMediaModel.fromJson(json);

      expect(model.id, '7f8a9b0c-1d2e-3f4a-5b6c-7d8e9f0a1b2c');
      expect(model.campaignId, 'c1d2e3f4-a5b6-7c8d-9e0f-1a2b3c4d5e6f');
      expect(model.mediaType, 'BANNER');
      expect(model.isBanner, isTrue);
      expect(model.isVideo, isFalse);
      expect(model.isImage, isFalse);
      expect(model.isReady, isTrue);
      expect(model.isDisabled, isFalse);
      expect(model.width, 728);
      expect(model.height, 90);
      expect(model.dimensionsText, '728x90');
      expect(model.fileSizeFormatted, '200.0 KB');
    });

    test('toJson serializes correctly', () {
      const model = CampaignMediaModel(
        id: 'media-uuid',
        campaignId: 'campaign-uuid',
        mediaType: 'VIDEO',
        fileUrl: 'https://cdn.vewra.com/video.mp4',
        title: 'Video Ad',
        durationSeconds: 30,
        status: 'READY',
      );

      final json = model.toJson();
      expect(json['id'], 'media-uuid');
      expect(json['campaign'], 'campaign-uuid');
      expect(json['media_type'], 'VIDEO');
      expect(json['duration_seconds'], 30);
    });

    test('copyWith updates state correctly', () {
      const model = CampaignMediaModel(
        id: 'media-uuid',
        campaignId: 'campaign-uuid',
        mediaType: 'IMAGE',
        fileUrl: 'url',
        title: 'Initial',
        status: 'READY',
      );

      final updated = model.copyWith(
        title: 'Updated Title',
        status: 'DISABLED',
        statusDisplay: 'Disabled',
      );

      expect(updated.title, 'Updated Title');
      expect(updated.status, 'DISABLED');
      expect(updated.isDisabled, isTrue);
      expect(updated.isReady, isFalse);
    });
  });
}

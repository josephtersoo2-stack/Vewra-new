import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/campaigns/models/ad_placement_model.dart';

void main() {
  group('AdPlacementModel Tests', () {
    test('fromJson deserializes complete placement payload correctly', () {
      final json = {
        'id': 'place-uuid-123',
        'placement_type': 'HOME_FEED',
        'placement_type_display': 'Home Feed',
        'priority': 25,
        'campaign_id': 'camp-uuid-456',
        'campaign_title': 'Promo Campaign',
        'campaign_status': 'ACTIVE',
        'media': {
          'id': 'media-uuid-789',
          'campaign': 'camp-uuid-456',
          'media_type': 'BANNER',
          'media_type_display': 'Banner Ad',
          'file_url': 'https://vewra.io/media/banner.jpg',
          'title': '728x90 Header Banner',
          'file_size': 2048,
          'file_size_formatted': '2.0 KB',
          'status': 'READY',
          'status_display': 'Ready',
        },
        'start_date': '2026-08-30T00:00:00Z',
        'end_date': '2026-09-30T00:00:00Z',
        'status': 'ACTIVE',
        'status_display': 'Active',
      };

      final model = AdPlacementModel.fromJson(json);

      expect(model.id, equals('place-uuid-123'));
      expect(model.placementType, equals('HOME_FEED'));
      expect(model.placementTypeDisplay, equals('Home Feed'));
      expect(model.priority, equals(25));
      expect(model.campaignId, equals('camp-uuid-456'));
      expect(model.campaignTitle, equals('Promo Campaign'));
      expect(model.campaignStatus, equals('ACTIVE'));
      expect(model.status, equals('ACTIVE'));
      expect(model.isActive, isTrue);
      expect(model.isHomeFeed, isTrue);
      expect(model.isHeader, isFalse);
      expect(model.media, isNotNull);
      expect(model.media!.title, equals('728x90 Header Banner'));
      expect(model.media!.fileUrl, equals('https://vewra.io/media/banner.jpg'));
    });

    test('toJson serializes correctly and copyWith updates state', () {
      const model = AdPlacementModel(
        id: 'place-1',
        placementType: 'POPUP',
        priority: 50,
        campaignId: 'camp-1',
        campaignTitle: 'Popup Test',
        status: 'PAUSED',
      );

      expect(model.isPopup, isTrue);
      expect(model.isPaused, isTrue);
      expect(model.isActive, isFalse);

      final updated = model.copyWith(
        status: 'ACTIVE',
        priority: 100,
      );

      expect(updated.id, equals('place-1'));
      expect(updated.status, equals('ACTIVE'));
      expect(updated.priority, equals(100));
      expect(updated.isActive, isTrue);

      final json = updated.toJson();
      expect(json['id'], equals('place-1'));
      expect(json['status'], equals('ACTIVE'));
      expect(json['priority'], equals(100));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/features/campaigns/models/campaign_media_model.dart';
import 'package:vewra_mobile/features/campaigns/data/campaign_media_repository.dart';
import 'package:vewra_mobile/features/campaigns/providers/campaign_media_provider.dart';

class MockCampaignMediaRepository implements CampaignMediaRepository {
  List<CampaignMediaModel> mockData = [
    const CampaignMediaModel(
      id: 'media-1',
      campaignId: 'camp-123',
      mediaType: 'BANNER',
      title: 'Top Banner',
      fileUrl: 'http://example.com/banner.png',
      width: 728,
      height: 90,
      status: 'READY',
      statusDisplay: 'Ready',
    ),
    const CampaignMediaModel(
      id: 'media-2',
      campaignId: 'camp-123',
      mediaType: 'VIDEO',
      title: 'Promo Video',
      fileUrl: 'http://example.com/video.mp4',
      durationSeconds: 15,
      status: 'READY',
      statusDisplay: 'Ready',
    ),
  ];

  @override
  Future<List<CampaignMediaModel>> getMediaForCampaign(
    String campaignId, {
    String? mediaType,
    String? status,
  }) async {
    var result = mockData.where((m) => m.campaignId == campaignId).toList();
    if (mediaType != null && mediaType != 'ALL') {
      result = result.where((m) => m.mediaType == mediaType).toList();
    }
    if (status != null && status != 'ALL') {
      result = result.where((m) => m.status == status).toList();
    }
    return result;
  }

  @override
  Future<CampaignMediaModel> uploadMedia({
    required String campaignId,
    required String filePath,
    required String fileName,
    required String mediaType,
    required String title,
    String description = '',
  }) async {
    final newMedia = CampaignMediaModel(
      id: 'media-new',
      campaignId: campaignId,
      mediaType: mediaType,
      fileUrl: 'http://example.com/uploaded.png',
      title: title,
      description: description,
      status: 'READY',
    );
    mockData.add(newMedia);
    return newMedia;
  }

  @override
  Future<CampaignMediaModel> updateMedia(
    String mediaId, {
    String? title,
    String? description,
    String? status,
  }) async {
    final idx = mockData.indexWhere((m) => m.id == mediaId);
    final updated = mockData[idx].copyWith(
      title: title,
      description: description,
      status: status,
    );
    mockData[idx] = updated;
    return updated;
  }

  @override
  Future<bool> disableMedia(String mediaId) async {
    final idx = mockData.indexWhere((m) => m.id == mediaId);
    if (idx != -1) {
      mockData[idx] = mockData[idx].copyWith(status: 'DISABLED', statusDisplay: 'Disabled');
      return true;
    }
    return false;
  }

  @override
  Future<bool> restoreMedia(String mediaId) async {
    final idx = mockData.indexWhere((m) => m.id == mediaId);
    if (idx != -1) {
      mockData[idx] = mockData[idx].copyWith(status: 'READY', statusDisplay: 'Ready');
      return true;
    }
    return false;
  }
}

void main() {
  group('Campaign Media Provider Tests', () {
    late ProviderContainer container;
    late MockCampaignMediaRepository mockRepo;

    setUp(() {
      mockRepo = MockCampaignMediaRepository();
      container = ProviderContainer(
        overrides: [
          campaignMediaRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial load returns mock media assets', () async {
      final notifier = container.read(campaignMediaListProvider('camp-123').notifier);
      await notifier.loadMedia();

      final state = container.read(campaignMediaListProvider('camp-123'));
      expect(state.value, isNotNull);
      expect(state.value!.length, 2);
      expect(state.value!.first.title, 'Top Banner');
    });

    test('Filter by mediaType VIDEO returns only video assets', () async {
      final notifier = container.read(campaignMediaListProvider('camp-123').notifier);
      await notifier.loadMedia(mediaType: 'VIDEO');

      final state = container.read(campaignMediaListProvider('camp-123'));
      expect(state.value!.length, 1);
      expect(state.value!.first.mediaType, 'VIDEO');
      expect(state.value!.first.title, 'Promo Video');
    });

    test('disableMedia changes status to DISABLED', () async {
      final notifier = container.read(campaignMediaListProvider('camp-123').notifier);
      await notifier.loadMedia();

      final success = await notifier.disableMedia('media-1');
      expect(success, isTrue);

      final state = container.read(campaignMediaListProvider('camp-123'));
      final disabledItem = state.value!.firstWhere((m) => m.id == 'media-1');
      expect(disabledItem.status, 'DISABLED');
      expect(disabledItem.isDisabled, isTrue);
    });

    test('restoreMedia changes status back to READY', () async {
      final notifier = container.read(campaignMediaListProvider('camp-123').notifier);
      await notifier.loadMedia();
      await notifier.disableMedia('media-1');

      final success = await notifier.restoreMedia('media-1');
      expect(success, isTrue);

      final state = container.read(campaignMediaListProvider('camp-123'));
      final restoredItem = state.value!.firstWhere((m) => m.id == 'media-1');
      expect(restoredItem.status, 'READY');
      expect(restoredItem.isReady, isTrue);
    });
  });
}

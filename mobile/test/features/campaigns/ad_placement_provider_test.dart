import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/features/campaigns/models/ad_placement_model.dart';
import 'package:vewra_mobile/features/campaigns/data/campaign_repository.dart';
import 'package:vewra_mobile/features/campaigns/providers/ad_placement_provider.dart';

class FakeAdPlacementRepository implements CampaignRepository {
  List<AdPlacementModel> mockPlacements = [];

  @override
  Future<List<AdPlacementModel>> getActiveAdsByLocation(
    String placementType, {
    int limit = 10,
  }) async {
    return mockPlacements
        .where((p) => p.placementType == placementType && p.isActive)
        .toList();
  }

  @override
  Future<List<AdPlacementModel>> getCampaignPlacements(
    String campaignId, {
    String? status,
    String? type,
  }) async {
    return mockPlacements.where((p) => p.campaignId == campaignId).toList();
  }

  @override
  Future<AdPlacementModel> createCampaignPlacement(
    String campaignId,
    Map<String, dynamic> data,
  ) async {
    final created = AdPlacementModel(
      id: 'created-id-${mockPlacements.length + 1}',
      placementType: data['placement_type'] ?? 'HOME_FEED',
      priority: data['priority'] ?? 10,
      campaignId: campaignId,
      status: data['status'] ?? 'DRAFT',
    );
    mockPlacements.add(created);
    return created;
  }

  @override
  Future<AdPlacementModel> updateCampaignPlacement(
    String id,
    Map<String, dynamic> data,
  ) async {
    final index = mockPlacements.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final updated = mockPlacements[index].copyWith(
        status: data['status'],
        priority: data['priority'],
      );
      mockPlacements[index] = updated;
      return updated;
    }
    throw Exception('Placement not found');
  }

  @override
  Future<AdPlacementModel> disableCampaignPlacement(String id) async {
    return updateCampaignPlacement(id, {'status': 'DISABLED'});
  }

  @override
  Future<AdPlacementModel> restoreCampaignPlacement(String id) async {
    return updateCampaignPlacement(id, {'status': 'ACTIVE'});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AdPlacement Providers Tests', () {
    late FakeAdPlacementRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeAdPlacementRepository();
      fakeRepo.mockPlacements = [
        const AdPlacementModel(
          id: 'p1',
          placementType: 'HOME_FEED',
          priority: 20,
          campaignId: 'camp-1',
          status: 'ACTIVE',
        ),
        const AdPlacementModel(
          id: 'p2',
          placementType: 'HOME_FEED',
          priority: 10,
          campaignId: 'camp-1',
          status: 'PAUSED',
        ),
      ];

      container = ProviderContainer(
        overrides: [
          adPlacementRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('activeAdsByLocationProvider fetches only active placements for given location', () async {
      final activeHomeAds = await container.read(activeAdsByLocationProvider('HOME_FEED').future);

      expect(activeHomeAds.length, equals(1));
      expect(activeHomeAds.first.id, equals('p1'));
      expect(activeHomeAds.first.isActive, isTrue);
    });

    test('CampaignPlacementsNotifier creates, activates, and disables placements', () async {
      final notifier = container.read(campaignPlacementsProvider('camp-1').notifier);

      // Load initial placements
      await notifier.loadPlacements();
      var state = container.read(campaignPlacementsProvider('camp-1'));
      expect(state.value?.length, equals(2));

      // Create new placement
      final created = await notifier.createPlacement({
        'placement_type': 'HEADER',
        'priority': 50,
        'status': 'DRAFT',
      });
      expect(created?.id, equals('created-id-3'));

      // Activate p2
      await notifier.activatePlacement('p2');
      state = container.read(campaignPlacementsProvider('camp-1'));
      final p2 = state.value?.firstWhere((p) => p.id == 'p2');
      expect(p2?.isActive, isTrue);

      // Disable p1
      await notifier.disablePlacement('p1');
      state = container.read(campaignPlacementsProvider('camp-1'));
      final p1 = state.value?.firstWhere((p) => p.id == 'p1');
      expect(p1?.isDisabled, isTrue);
    });
  });
}

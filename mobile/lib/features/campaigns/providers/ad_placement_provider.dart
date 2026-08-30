import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/campaign_repository.dart';
import '../models/ad_placement_model.dart';

final adPlacementRepositoryProvider = Provider<CampaignRepository>((ref) {
  return CampaignRepository();
});

/// Future provider fetching active, approved ads by surface location (e.g. HOME_FEED, HEADER, POPUP).
final activeAdsByLocationProvider = FutureProvider.autoDispose.family<List<AdPlacementModel>, String>((ref, placementType) async {
  final repository = ref.watch(adPlacementRepositoryProvider);
  return await repository.getActiveAdsByLocation(placementType);
});

/// State notifier managing placements for a specific campaign.
class CampaignPlacementsNotifier extends StateNotifier<AsyncValue<List<AdPlacementModel>>> {
  final CampaignRepository _repository;
  final String _campaignId;

  CampaignPlacementsNotifier(this._repository, this._campaignId)
      : super(const AsyncValue.loading()) {
    loadPlacements();
  }

  Future<void> loadPlacements({String? status, String? type}) async {
    try {
      state = const AsyncValue.loading();
      final placements = await _repository.getCampaignPlacements(
        _campaignId,
        status: status,
        type: type,
      );
      state = AsyncValue.data(placements);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AdPlacementModel?> createPlacement(Map<String, dynamic> data) async {
    try {
      final created = await _repository.createCampaignPlacement(_campaignId, data);
      final current = state.value ?? [];
      state = AsyncValue.data([created, ...current]);
      return created;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> activatePlacement(String id) async {
    try {
      final updated = await _repository.updateCampaignPlacement(id, {'status': 'ACTIVE'});
      _updateLocalPlacement(updated);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pausePlacement(String id) async {
    try {
      final updated = await _repository.updateCampaignPlacement(id, {'status': 'PAUSED'});
      _updateLocalPlacement(updated);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> disablePlacement(String id) async {
    try {
      final disabled = await _repository.disableCampaignPlacement(id);
      _updateLocalPlacement(disabled);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> restorePlacement(String id) async {
    try {
      final restored = await _repository.restoreCampaignPlacement(id);
      _updateLocalPlacement(restored);
    } catch (e) {
      rethrow;
    }
  }

  void _updateLocalPlacement(AdPlacementModel updated) {
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.map((p) => p.id == updated.id ? updated : p).toList(),
    );
  }
}

final campaignPlacementsProvider = StateNotifierProvider.autoDispose
    .family<CampaignPlacementsNotifier, AsyncValue<List<AdPlacementModel>>, String>((ref, campaignId) {
  final repository = ref.watch(adPlacementRepositoryProvider);
  return CampaignPlacementsNotifier(repository, campaignId);
});

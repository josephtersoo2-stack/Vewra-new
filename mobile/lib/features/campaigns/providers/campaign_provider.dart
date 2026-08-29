import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campaign_model.dart';
import '../data/campaign_repository.dart';

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  return CampaignRepository();
});

final campaignTypeFilterProvider = StateProvider<String>((ref) => 'ALL');
final campaignStatusFilterProvider = StateProvider<String>((ref) => 'ALL');

class CampaignListNotifier extends StateNotifier<AsyncValue<List<CampaignModel>>> {
  final CampaignRepository _repository;
  final Ref _ref;

  CampaignListNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadCampaigns();
  }

  Future<void> loadCampaigns({String? search}) async {
    state = const AsyncValue.loading();
    try {
      final type = _ref.read(campaignTypeFilterProvider);
      final status = _ref.read(campaignStatusFilterProvider);

      final campaigns = await _repository.getCampaigns(
        type: type == 'ALL' ? null : type,
        status: status == 'ALL' ? null : status,
        search: search,
      );
      state = AsyncValue.data(campaigns);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<CampaignModel?> createCampaign({
    required String title,
    required String campaignType,
    String description = '',
    double budget = 0.0,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final created = await _repository.createCampaign(
        title: title,
        campaignType: campaignType,
        description: description,
        budget: budget,
        startDate: startDate,
        endDate: endDate,
      );
      // Reload list after creation
      await loadCampaigns();
      return created;
    } catch (e) {
      return null;
    }
  }

  Future<bool> submitForReview(String id) async {
    try {
      await _repository.submitForReview(id);
      await loadCampaigns();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> pauseCampaign(String id) async {
    try {
      await _repository.pauseCampaign(id);
      await loadCampaigns();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final campaignListProvider =
    StateNotifierProvider<CampaignListNotifier, AsyncValue<List<CampaignModel>>>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return CampaignListNotifier(repository, ref);
});

final campaignDetailProvider =
    FutureProvider.family<CampaignModel, String>((ref, id) async {
  final repository = ref.watch(campaignRepositoryProvider);
  return await repository.getCampaignDetails(id);
});

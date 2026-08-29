import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campaign_media_model.dart';
import '../data/campaign_media_repository.dart';
import '../data/campaign_media_api_service.dart';

final campaignMediaApiServiceProvider = Provider<CampaignMediaApiService>((ref) {
  return CampaignMediaApiService();
});

final campaignMediaRepositoryProvider = Provider<CampaignMediaRepository>((ref) {
  final apiService = ref.watch(campaignMediaApiServiceProvider);
  return CampaignMediaRepository(apiService: apiService);
});

final campaignMediaTypeFilterProvider = StateProvider<String>((ref) => 'ALL');

class CampaignMediaListNotifier
    extends StateNotifier<AsyncValue<List<CampaignMediaModel>>> {
  final CampaignMediaRepository _repository;
  final String _campaignId;
  final Ref _ref;

  CampaignMediaListNotifier({
    required CampaignMediaRepository repository,
    required String campaignId,
    required Ref ref,
  })  : _repository = repository,
        _campaignId = campaignId,
        _ref = ref,
        super(const AsyncValue.loading()) {
    loadMedia();
  }

  Future<void> loadMedia({String? mediaType, String? status}) async {
    state = const AsyncValue.loading();
    try {
      final activeType = mediaType ?? _ref.read(campaignMediaTypeFilterProvider);
      final media = await _repository.getMediaForCampaign(
        _campaignId,
        mediaType: activeType == 'ALL' ? null : activeType,
        status: status,
      );
      state = AsyncValue.data(media);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<CampaignMediaModel?> uploadMedia({
    required String filePath,
    required String fileName,
    required String mediaType,
    required String title,
    String description = '',
  }) async {
    try {
      final uploaded = await _repository.uploadMedia(
        campaignId: _campaignId,
        filePath: filePath,
        fileName: fileName,
        mediaType: mediaType,
        title: title,
        description: description,
      );

      final current = state.value ?? [];
      state = AsyncValue.data([uploaded, ...current]);
      return uploaded;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateMedia(
    String mediaId, {
    String? title,
    String? description,
    String? status,
  }) async {
    try {
      final updated = await _repository.updateMedia(
        mediaId,
        title: title,
        description: description,
        status: status,
      );

      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((item) => item.id == mediaId ? updated : item).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> disableMedia(String mediaId) async {
    try {
      final success = await _repository.disableMedia(mediaId);
      if (success) {
        final current = state.value ?? [];
        state = AsyncValue.data(
          current.map((item) {
            if (item.id == mediaId) {
              return item.copyWith(status: 'DISABLED', statusDisplay: 'Disabled');
            }
            return item;
          }).toList(),
        );
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restoreMedia(String mediaId) async {
    try {
      final success = await _repository.restoreMedia(mediaId);
      if (success) {
        final current = state.value ?? [];
        state = AsyncValue.data(
          current.map((item) {
            if (item.id == mediaId) {
              return item.copyWith(status: 'READY', statusDisplay: 'Ready');
            }
            return item;
          }).toList(),
        );
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}

final campaignMediaListProvider = StateNotifierProvider.family<
    CampaignMediaListNotifier,
    AsyncValue<List<CampaignMediaModel>>,
    String>((ref, campaignId) {
  final repo = ref.watch(campaignMediaRepositoryProvider);
  return CampaignMediaListNotifier(
    repository: repo,
    campaignId: campaignId,
    ref: ref,
  );
});

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/features/campaigns/models/campaign_model.dart';
import 'package:vewra_mobile/features/campaigns/data/campaign_repository.dart';
import 'package:vewra_mobile/features/campaigns/providers/campaign_provider.dart';

class MockCampaignRepository implements CampaignRepository {
  final List<CampaignModel> _campaigns = [
    const CampaignModel(
      id: 'c-1',
      title: 'Mock Task Campaign',
      campaignType: 'TASK',
      status: 'ACTIVE',
      budget: 100.0,
    ),
    const CampaignModel(
      id: 'c-2',
      title: 'Mock Ad Campaign',
      campaignType: 'ADVERTISEMENT',
      status: 'DRAFT',
      budget: 250.0,
    ),
  ];

  @override
  Future<List<CampaignModel>> getCampaigns({String? status, String? type, String? search}) async {
    var result = List<CampaignModel>.from(_campaigns);
    if (type != null && type != 'ALL') {
      result = result.where((c) => c.campaignType == type).toList();
    }
    if (status != null && status != 'ALL') {
      result = result.where((c) => c.status == status).toList();
    }
    return result;
  }

  @override
  Future<CampaignModel> getCampaignDetails(String id) async {
    return _campaigns.firstWhere((c) => c.id == id);
  }

  @override
  Future<CampaignModel> createCampaign({
    required String title,
    required String campaignType,
    String description = '',
    double budget = 0.0,
    String? startDate,
    String? endDate,
  }) async {
    final created = CampaignModel(
      id: 'c-${_campaigns.length + 1}',
      title: title,
      campaignType: campaignType,
      status: 'DRAFT',
      budget: budget,
      description: description,
    );
    _campaigns.add(created);
    return created;
  }

  @override
  Future<CampaignModel> submitForReview(String id) async {
    final idx = _campaigns.indexWhere((c) => c.id == id);
    final updated = _campaigns[idx].copyWith(status: 'PENDING_REVIEW');
    _campaigns[idx] = updated;
    return updated;
  }

  @override
  Future<CampaignModel> pauseCampaign(String id) async {
    final idx = _campaigns.indexWhere((c) => c.id == id);
    final updated = _campaigns[idx].copyWith(status: 'PAUSED');
    _campaigns[idx] = updated;
    return updated;
  }
}

void main() {
  group('Campaign Provider Tests', () {
    late ProviderContainer container;
    late MockCampaignRepository mockRepo;

    setUp(() {
      mockRepo = MockCampaignRepository();
      container = ProviderContainer(
        overrides: [
          campaignRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('Initial load returns mock campaigns list', () async {
      // Wait for notifier load
      await container.read(campaignListProvider.notifier).loadCampaigns();
      final state = container.read(campaignListProvider);

      expect(state.hasValue, isTrue);
      expect(state.value!.length, 2);
      expect(state.value![0].title, 'Mock Task Campaign');
    });

    test('Filter by type TASK returns only task campaigns', () async {
      container.read(campaignTypeFilterProvider.notifier).state = 'TASK';
      await container.read(campaignListProvider.notifier).loadCampaigns();

      final state = container.read(campaignListProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.length, 1);
      expect(state.value![0].campaignType, 'TASK');
    });

    test('createCampaign adds new DRAFT campaign', () async {
      final created = await container.read(campaignListProvider.notifier).createCampaign(
            title: 'New Spon Campaign',
            campaignType: 'SPONSORED_CONTENT',
            budget: 500.0,
          );

      expect(created, isNotNull);
      expect(created!.status, 'DRAFT');
      expect(created.title, 'New Spon Campaign');

      final state = container.read(campaignListProvider);
      expect(state.value!.length, 3);
    });

    test('submitForReview transitions status to PENDING_REVIEW', () async {
      final success = await container.read(campaignListProvider.notifier).submitForReview('c-2');
      expect(success, isTrue);

      final state = container.read(campaignListProvider);
      final c2 = state.value!.firstWhere((c) => c.id == 'c-2');
      expect(c2.status, 'PENDING_REVIEW');
    });
  });
}

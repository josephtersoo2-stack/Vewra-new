import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../../../core/widgets/layout/app_header.dart';
import '../../../core/widgets/feedback/app_empty_state.dart';
import '../../../core/widgets/feedback/app_error_state.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../providers/campaign_provider.dart';
import '../widgets/campaign_card.dart';

class CampaignListScreen extends ConsumerStatefulWidget {
  const CampaignListScreen({super.key});

  @override
  ConsumerState<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends ConsumerState<CampaignListScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _typeFilters = const [
    {'label': 'All Types', 'value': 'ALL'},
    {'label': 'Tasks', 'value': 'TASK'},
    {'label': 'Ads', 'value': 'ADVERTISEMENT'},
    {'label': 'Sponsored', 'value': 'SPONSORED_CONTENT'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(campaignListProvider);
    final activeTypeFilter = ref.watch(campaignTypeFilterProvider);

    return AppScaffold(
      body: Column(
        children: [
          const AppHeader(
            title: 'Available Campaigns',
            subtitle: 'Explore active advertiser campaigns & verified tasks',
            showBackButton: true,
          ),

          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.space16,
              vertical: AppConstants.space8,
            ),
            child: AppTextField(
              hint: 'Search campaigns...',
              controller: _searchController,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(campaignListProvider.notifier).loadCampaigns();
                      },
                    )
                  : null,
              onChanged: (val) {
                ref.read(campaignListProvider.notifier).loadCampaigns(search: val.trim());
              },
            ),
          ),

          // Horizontal Filter Chips
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
              itemCount: _typeFilters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final filter = _typeFilters[idx];
                final isSelected = activeTypeFilter == filter['value'];
                return ChoiceChip(
                  label: Text(filter['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(campaignTypeFilterProvider.notifier).state = filter['value']!;
                    ref.read(campaignListProvider.notifier).loadCampaigns();
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppConstants.space8),

          // Main List View
          Expanded(
            child: campaignsAsync.when(
              data: (campaigns) {
                if (campaigns.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.campaign_outlined,
                    title: 'No Campaigns Available',
                    description: 'Check back soon for new partner campaigns and promotional tasks.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(campaignListProvider.notifier).loadCampaigns();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppConstants.space16),
                    itemCount: campaigns.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppConstants.space12),
                    itemBuilder: (context, index) {
                      final campaign = campaigns[index];
                      return CampaignCard(
                        campaign: campaign,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.campaignDetails,
                            arguments: campaign,
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => AppErrorState(
                title: 'Unable to Load Campaigns',
                message: err.toString().replaceAll('Exception: ', ''),
                onRetry: () => ref.read(campaignListProvider.notifier).loadCampaigns(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

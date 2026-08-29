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
import '../../../core/widgets/buttons/app_button.dart';
import '../models/campaign_model.dart';
import '../providers/campaign_provider.dart';
import '../widgets/campaign_card.dart';

class CampaignListScreen extends ConsumerStatefulWidget {
  const CampaignListScreen({super.key});

  @override
  ConsumerState<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends ConsumerState<CampaignListScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _typeFilters = [
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

  void _showCreateCampaignModal() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final budgetCtrl = TextEditingController(text: '100.00');
    String selectedType = 'TASK';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) => Container(
          padding: EdgeInsets.only(
            top: AppConstants.space24,
            left: AppConstants.space20,
            right: AppConstants.space20,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + AppConstants.space24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusXl),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Campaign',
                      style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.space16),
                AppTextField(
                  label: 'Campaign Title',
                  hint: 'e.g. Summer Promo 2026',
                  controller: titleCtrl,
                  prefixIcon: const Icon(Icons.campaign_outlined, size: 20),
                ),
                const SizedBox(height: AppConstants.space16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Campaign Type',
                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'TASK', child: Text('Task Campaign')),
                    DropdownMenuItem(value: 'ADVERTISEMENT', child: Text('Advertisement Campaign')),
                    DropdownMenuItem(value: 'SPONSORED_CONTENT', child: Text('Sponsored Content')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: AppConstants.space16),
                AppTextField(
                  label: 'Budget (USD)',
                  hint: '100.00',
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
                ),
                const SizedBox(height: AppConstants.space16),
                AppTextField(
                  label: 'Description',
                  hint: 'Brief summary of the campaign goals...',
                  controller: descCtrl,
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.space24),
                AppButton(
                  text: 'Create Draft Campaign',
                  isLoading: isSubmitting,
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a campaign title'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    setModalState(() => isSubmitting = true);
                    final budget = double.tryParse(budgetCtrl.text) ?? 0.0;
                    final created = await ref.read(campaignListProvider.notifier).createCampaign(
                          title: title,
                          campaignType: selectedType,
                          description: descCtrl.text.trim(),
                          budget: budget,
                        );
                    if (mounted) {
                      Navigator.pop(modalContext);
                      if (created != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✓ Campaign created in DRAFT status!'),
                            backgroundColor: AppColors.emerald,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(campaignListProvider);
    final activeTypeFilter = ref.watch(campaignTypeFilterProvider);

    return AppScaffold(
      body: Column(
        children: [
          AppHeader(
            title: 'Campaigns Platform',
            subtitle: 'Advertising & verified task campaigns ecosystem',
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLight),
                tooltip: 'Create Campaign',
                onPressed: _showCreateCampaignModal,
              ),
            ],
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
              separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                  return AppEmptyState(
                    icon: Icons.campaign_outlined,
                    title: 'No Campaigns Found',
                    description: 'Create your first campaign or adjust the filters above.',
                    actionText: 'Create Campaign',
                    onAction: _showCreateCampaignModal,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(campaignListProvider.notifier).loadCampaigns();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppConstants.space16),
                    itemCount: campaigns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppConstants.space12),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../../../core/widgets/layout/app_header.dart';
import '../../../core/widgets/feedback/app_empty_state.dart';
import '../../../core/widgets/feedback/app_error_state.dart';
import '../providers/campaign_media_provider.dart';
import '../widgets/campaign_media_card.dart';

class CampaignMediaScreen extends ConsumerStatefulWidget {
  final String campaignId;
  final String campaignTitle;
  final bool isAdvertiser;

  const CampaignMediaScreen({
    super.key,
    required this.campaignId,
    this.campaignTitle = 'Campaign',
    this.isAdvertiser = false,
  });

  @override
  ConsumerState<CampaignMediaScreen> createState() => _CampaignMediaScreenState();
}

class _CampaignMediaScreenState extends ConsumerState<CampaignMediaScreen> {
  final List<Map<String, String>> _typeFilters = const [
    {'label': 'All Assets', 'value': 'ALL'},
    {'label': 'Videos', 'value': 'VIDEO'},
    {'label': 'Banners', 'value': 'BANNER'},
    {'label': 'Images', 'value': 'IMAGE'},
  ];

  @override
  Widget build(BuildContext context) {
    final mediaAsync = ref.watch(campaignMediaListProvider(widget.campaignId));
    final activeTypeFilter = ref.watch(campaignMediaTypeFilterProvider);

    return AppScaffold(
      body: Column(
        children: [
          AppHeader(
            title: 'Campaign Media',
            subtitle: widget.campaignTitle,
            showBackButton: true,
          ),

          // Horizontal Filter Chips
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.space16,
                vertical: AppConstants.space4,
              ),
              itemCount: _typeFilters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final filter = _typeFilters[idx];
                final isSelected = activeTypeFilter == filter['value'];
                return ChoiceChip(
                  label: Text(filter['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(campaignMediaTypeFilterProvider.notifier).state = filter['value']!;
                    ref
                        .read(campaignMediaListProvider(widget.campaignId).notifier)
                        .loadMedia(mediaType: filter['value']);
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

          // Media List
          Expanded(
            child: mediaAsync.when(
              data: (mediaList) {
                if (mediaList.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.perm_media_outlined,
                    title: 'No Media Assets',
                    description: 'No creative assets have been uploaded for this campaign yet.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(campaignMediaListProvider(widget.campaignId).notifier)
                        .loadMedia();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppConstants.space16),
                    itemCount: mediaList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppConstants.space12),
                    itemBuilder: (context, index) {
                      final media = mediaList[index];
                      return CampaignMediaCard(
                        media: media,
                        isManageable: widget.isAdvertiser,
                        onDisable: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Disable Media Asset?'),
                              content: const Text(
                                'This media creative will no longer be served in campaigns.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Disable',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && context.mounted) {
                            await ref
                                .read(campaignMediaListProvider(widget.campaignId).notifier)
                                .disableMedia(media.id);
                          }
                        },
                        onRestore: () async {
                          await ref
                              .read(campaignMediaListProvider(widget.campaignId).notifier)
                              .restoreMedia(media.id);
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
                title: 'Unable to Load Media',
                message: err.toString().replaceAll('Exception: ', ''),
                onRetry: () => ref
                    .read(campaignMediaListProvider(widget.campaignId).notifier)
                    .loadMedia(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

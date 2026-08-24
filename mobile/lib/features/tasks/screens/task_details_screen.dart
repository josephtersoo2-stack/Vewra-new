import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/routing/app_routes.dart';
import '../../../models/task_model.dart';
import '../../../services/dummy_data_service.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/buttons/app_icon_button.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/layout/app_scaffold.dart';

/// Detailed Task View outlining verification requirements, search keywords, and reward structure.
class TaskDetailsScreen extends StatelessWidget {
  final TaskModel? task;

  const TaskDetailsScreen({
    super.key,
    this.task,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTask = task ?? DummyDataService.tasks.first;

    return AppScaffold(
      body: Column(
        children: [
          // Top Navigation Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.space16,
              vertical: AppConstants.space12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  iconSize: 18,
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  AppStrings.taskDetails,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppIconButton(
                  icon: Icons.share_outlined,
                  iconSize: 20,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task link copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Thumbnail Banner
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: AppConstants.borderRadiusLg,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.youtubeRed.withValues(alpha: 0.95),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.youtubeRed.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.overlayDark,
                              borderRadius: AppConstants.borderRadiusSm,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              effectiveTask.category,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.overlayDark,
                              borderRadius: AppConstants.borderRadiusSm,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  Formatters.formatDuration(effectiveTask.durationMinutes),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.space16),
                  // Title & Channel
                  Text(
                    effectiveTask.title,
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded, size: 16, color: AppColors.primaryLight),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        effectiveTask.channelName,
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.space20),
                  // Reward Payout Card
                  Container(
                    padding: const EdgeInsets.all(AppConstants.space16),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: AppConstants.borderRadiusMd,
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.rewardInfo,
                              style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '+${effectiveTask.rewardCoins} Coins',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.coinGold,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: AppConstants.borderRadiusFull,
                          ),
                          child: Text(
                            '≈ ${Formatters.formatCurrency(effectiveTask.rewardFiat)}',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.coinGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.space20),
                  // Search Keyword Assistance
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.search_rounded, size: 18, color: AppColors.secondary),
                                const SizedBox(width: 6),
                                Text(
                                  AppStrings.searchInstructions,
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: effectiveTask.searchKeywords));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Search keywords copied!')),
                                );
                              },
                              borderRadius: AppConstants.borderRadiusSm,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.copy_rounded, size: 14, color: AppColors.primaryLight),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Copy',
                                      style: AppTypography.labelSmall.copyWith(color: AppColors.primaryLight),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.space8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppConstants.space12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            borderRadius: AppConstants.borderRadiusSm,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            effectiveTask.searchKeywords,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.space20),
                  // Instructions Checklist
                  Text(
                    AppStrings.howItWorks,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space12),
                  ...effectiveTask.instructions.map(
                    (inst) => Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.space10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 12, color: Colors.black),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              inst,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.space32),
                ],
              ),
            ),
          ),
          // Bottom Sticky Action Button
          Container(
            padding: const EdgeInsets.all(AppConstants.space16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: AppButton(
              key: const Key('start_watching_button'),
              text: AppStrings.startWatching,
              prefixIcon: const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 22),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.browser,
                  arguments: effectiveTask,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

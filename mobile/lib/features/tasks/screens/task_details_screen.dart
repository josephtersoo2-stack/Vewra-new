import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/routing/app_routes.dart';
import '../../../models/task_model.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/buttons/app_icon_button.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../providers/task_feed_provider.dart';
import '../providers/task_details_provider.dart';
import '../../browser/models/watch_session_model.dart';
import '../../browser/providers/tracking_session_provider.dart';

/// Detailed Task View with server eligibility verification, instructions, and authenticated session initiation.
class TaskDetailsScreen extends ConsumerStatefulWidget {
  final TaskModel? task;

  const TaskDetailsScreen({
    super.key,
    this.task,
  });

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  bool _isStarting = false;

  Future<void> _handleStartTask(TaskModel task) async {
    setState(() => _isStarting = true);

    try {
      final repo = ref.read(taskRepositoryProvider);
      final result = await repo.startTask(task.id);

      final watchSession = result['watch_session'] as WatchSessionModel?;
      if (watchSession != null && watchSession.watchToken != null) {
        ref.read(trackingSessionProvider.notifier).initializeSession(
              session: watchSession,
              watchToken: watchSession.watchToken!,
            );
      }

      setState(() => _isStarting = false);

      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.browser,
          arguments: task,
        );
      }
    } catch (e) {
      setState(() => _isStarting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final passedTask = widget.task;
    final detailsAsync = passedTask != null
        ? ref.watch(taskDetailsProvider(passedTask.id))
        : null;

    final effectiveTask = detailsAsync?.task ?? passedTask ??
        const TaskModel(
          id: 'placeholder',
          title: 'Video Task Overview',
          rewardCoins: 20,
        );

    final eligibility = detailsAsync?.eligibility;
    final isLocked = eligibility != null && !eligibility.eligible;

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
                      fit: StackFit.expand,
                      children: [
                        if (effectiveTask.thumbnailUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: AppConstants.borderRadiusLg,
                            child: Image.network(
                              effectiveTask.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
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
                        // Duration Tag
                        Positioned(
                          bottom: AppConstants.space12,
                          right: AppConstants.space12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.space10,
                              vertical: AppConstants.space4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: AppConstants.borderRadiusSm,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  '${effectiveTask.requiredWatchSeconds}s required',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
                        effectiveTask.channelName.isNotEmpty
                            ? effectiveTask.channelName
                            : 'VEWRA Verified Creator',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (effectiveTask.quizRequired) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.quiz_outlined, size: 14, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Text(
                                'Quiz Required',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

                  // Eligibility Warning Banner if locked
                  if (isLocked) ...[
                    const SizedBox(height: AppConstants.space16),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.space14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: AppConstants.borderRadiusMd,
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lock_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: AppConstants.space10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Currently Locked',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  eligibility.reasons.join('\n'),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppConstants.space20),
                  // Search Keyword Assistance
                  if (effectiveTask.searchKeywords.isNotEmpty) ...[
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
                                    const SnackBar(
                                      content: Text('Keyword copied!'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.copy_rounded, size: 14, color: AppColors.primaryLight),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Copy',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.primaryLight,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.space12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: AppConstants.borderRadiusSm,
                            ),
                            child: SelectableText(
                              effectiveTask.searchKeywords,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.space20),
                  ],

                  // Description
                  if (effectiveTask.description.isNotEmpty) ...[
                    Text(
                      'Overview',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space8),
                    Text(
                      effectiveTask.description,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space20),
                  ],

                  // Verification Rules & Steps
                  Text(
                    AppStrings.verificationRules,
                    style: AppTypography.headlineSmall.copyWith(
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
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: AppButton(
              key: const Key('start_watching_button'),
              text: isLocked
                  ? 'Requirements Not Met'
                  : (_isStarting ? 'Starting Session...' : AppStrings.startWatching),
              isLoading: _isStarting,
              prefixIcon: isLocked
                  ? const Icon(Icons.lock_rounded, color: Colors.white, size: 20)
                  : const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 22),
              onPressed: isLocked || _isStarting
                  ? null
                  : () => _handleStartTask(effectiveTask),
            ),
          ),
        ],
      ),
    );
  }
}

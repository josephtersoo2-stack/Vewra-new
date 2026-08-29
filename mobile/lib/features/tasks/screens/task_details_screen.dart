import 'dart:math';
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
  String _currentSearchKeyword = '';

  @override
  void initState() {
    super.initState();
    _pickRandomKeyword(widget.task);
  }

  void _pickRandomKeyword(TaskModel? task) {
    final pool = <String>[];
    if (task != null) {
      if (task.keywords.isNotEmpty) {
        pool.addAll(task.keywords);
      } else if (task.searchKeywords.isNotEmpty) {
        pool.add(task.searchKeywords);
      }
    }
    if (pool.isNotEmpty) {
      final random = Random();
      final selected = pool[random.nextInt(pool.length)];
      setState(() {
        _currentSearchKeyword = selected;
      });
    }
  }

  Future<void> _handleStartTask(TaskModel task) async {
    final effectiveTask = _currentSearchKeyword.isNotEmpty
        ? task.copyWith(searchKeywords: _currentSearchKeyword)
        : task;

    if (effectiveTask.isCompleted) {
      Navigator.pushNamed(
        context,
        AppRoutes.browser,
        arguments: effectiveTask,
      );
      return;
    }

    setState(() => _isStarting = true);

    try {
      final repo = ref.read(taskRepositoryProvider);
      final result = await repo.startTask(effectiveTask.id);

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
          arguments: effectiveTask,
        );
      }
    } catch (e) {
      setState(() => _isStarting = false);
      if (mounted) {
        // Always allow the user to open and watch the video freely
        Navigator.pushNamed(
          context,
          AppRoutes.browser,
          arguments: effectiveTask,
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

    final displayKeyword = _currentSearchKeyword.isNotEmpty
        ? _currentSearchKeyword
        : effectiveTask.searchKeywords;

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
                                  '${Formatters.formatSeconds(effectiveTask.requiredWatchSeconds)} required',
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
                  // Task Category & Metadata Row (No video title)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'YouTube Video Task',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (effectiveTask.isCompleted || (eligibility?.alreadyCompleted ?? false)) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                              const SizedBox(width: 4),
                              Text(
                                '✓ Completed',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (effectiveTask.quizRequired) ...[
                        const SizedBox(width: 8),
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
                  const SizedBox(height: AppConstants.space16),

                  // Completed Notice Banner if user already finished this task
                  if (effectiveTask.isCompleted || (eligibility?.alreadyCompleted ?? false)) ...[
                    Container(
                      padding: const EdgeInsets.all(AppConstants.space14),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: AppConstants.borderRadiusMd,
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: AppColors.success, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Completed & Rewarded',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'You earned +${effectiveTask.rewardCoins} coins for this task. You can watch this video freely anytime for personal enjoyment!',
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
                    const SizedBox(height: AppConstants.space16),
                  ],
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
                              effectiveTask.rewardSummary,
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
                  // Search Keyword Assistance & Copy Action
                  if (displayKeyword.isNotEmpty) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryLight),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Assigned Search Keyword',
                                        style: AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (effectiveTask.keywords.length > 1) ...[
                                    IconButton(
                                      onPressed: () => _pickRandomKeyword(effectiveTask),
                                      icon: const Icon(Icons.shuffle_rounded, size: 18, color: AppColors.secondary),
                                      tooltip: 'Randomize keyword',
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: displayKeyword));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Copied: "$displayKeyword"'),
                                          backgroundColor: AppColors.success,
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.copy_rounded, size: 14),
                                    label: const Text('Copy'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: const Size(0, 32),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.space12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: AppConstants.borderRadiusSm,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: SelectableText(
                              displayKeyword,
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.space12),
                          Text(
                            '📌 Instructions:\n'
                            '1. Tap "Copy" to copy the keyword above.\n'
                            '2. Tap "Start Watching" below to open YouTube.\n'
                            '3. Paste keyword into YouTube search.\n'
                            '4. Tap the video matching the thumbnail shown above to start earning rewards!',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
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
              text: effectiveTask.isCompleted || (eligibility?.alreadyCompleted ?? false)
                  ? 'Watch Again'
                  : (_isStarting ? 'Starting Session...' : AppStrings.startWatching),
              isLoading: _isStarting,
              prefixIcon: const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 22),
              onPressed: _isStarting
                  ? null
                  : () => _handleStartTask(effectiveTask),
            ),
          ),
        ],
      ),
    );
  }
}

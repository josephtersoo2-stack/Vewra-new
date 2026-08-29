import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../tasks/models/task_model.dart';
import 'task_progress_modal.dart';

class TrackingHudOverlay extends StatelessWidget {
  final TaskModel task;
  final bool isTargetDetected;
  final bool isTracking;
  final double totalWatchedSeconds;
  final double sessionCoinsEarned;
  final bool isCompleted;
  final bool isGoogleLoggedIn;
  final VoidCallback? onSignInTap;

  const TrackingHudOverlay({
    super.key,
    required this.task,
    required this.isTargetDetected,
    required this.isTracking,
    required this.totalWatchedSeconds,
    required this.sessionCoinsEarned,
    required this.isCompleted,
    this.isGoogleLoggedIn = true,
    this.onSignInTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTargetDetected && !isCompleted) {
      // Floating banner guiding the user to find the target video
      return Positioned(
        bottom: 16.0 + MediaQuery.paddingOf(context).bottom,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              if (task.thumbnailUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    task.thumbnailUrl,
                    width: 50,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(width: 50, height: 32, child: Icon(CupertinoIcons.play_rectangle, size: 20)),
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔍 Search & Tap Matching Video',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      task.searchKeywords.isNotEmpty ? '"${task.searchKeywords}"' : 'Use copied search query',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: task.searchKeywords));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Search query copied: "${task.searchKeywords}"'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Copy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final isInterval = task.rewardType == 'per_time';
    final targetSeconds = task.requiredWatchSeconds > 0
        ? task.requiredWatchSeconds.toDouble()
        : 300.0;
    final percent = isInterval
        ? ((totalWatchedSeconds % targetSeconds) / targetSeconds).clamp(0.0, 1.0)
        : (totalWatchedSeconds / targetSeconds).clamp(0.0, 1.0);
    final percentInt = (percent * 100).toInt();

    return Positioned(
      bottom: 16.0 + MediaQuery.paddingOf(context).bottom,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => TaskProgressModal(
              taskTitle: 'Target YouTube Video',
              totalWatchedSeconds: totalWatchedSeconds,
              targetSeconds: targetSeconds,
              coinsEarned: sessionCoinsEarned,
              isCompleted: isCompleted,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? AppColors.success
                  : (isTracking ? AppColors.primaryLight : AppColors.border),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Task Progress',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.2)
                          : (!isGoogleLoggedIn
                              ? AppColors.warning.withValues(alpha: 0.2)
                              : (isTracking
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : AppColors.surfaceLight)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCompleted
                              ? CupertinoIcons.checkmark_circle_fill
                              : (!isGoogleLoggedIn
                                  ? CupertinoIcons.exclamationmark_triangle_fill
                                  : (isTracking
                                      ? CupertinoIcons.play_circle_fill
                                      : CupertinoIcons.pause_circle_fill)),
                          color: isCompleted
                              ? AppColors.success
                              : (!isGoogleLoggedIn
                                  ? AppColors.warning
                                  : (isTracking
                                      ? AppColors.primaryLight
                                      : AppColors.textMuted)),
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isCompleted
                              ? 'Complete'
                              : (!isGoogleLoggedIn
                                  ? 'Sign In Required'
                                  : (isTracking ? 'Active' : 'Paused')),
                          style: AppTypography.labelSmall.copyWith(
                            color: isCompleted
                                ? AppColors.success
                                : (!isGoogleLoggedIn
                                    ? AppColors.warning
                                    : (isTracking
                                        ? AppColors.primaryLight
                                        : AppColors.textMuted)),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    task.rewardType == 'per_time'
                        ? 'Interval: ${Formatters.formatSeconds(targetSeconds.toInt())} (+${task.rewardCoins} coins)'
                        : (task.rewardType == 'watch_all'
                            ? 'Full Watch (+${task.rewardCoins} coins)'
                            : 'Target: ${Formatters.formatSeconds(targetSeconds.toInt())} (+${task.rewardCoins} coins)'),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    isInterval
                        ? '${Formatters.formatTimer((totalWatchedSeconds % targetSeconds).toInt())} / ${Formatters.formatTimer(targetSeconds.toInt())} ($percentInt%)'
                        : '${Formatters.formatTimer(totalWatchedSeconds.toInt())} / ${Formatters.formatTimer(targetSeconds.toInt())} ($percentInt%)',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 6,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Do not close the app or minimize player',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  if (sessionCoinsEarned > 0)
                    Text(
                      '+${sessionCoinsEarned.toInt()} Coins earned',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.coinGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

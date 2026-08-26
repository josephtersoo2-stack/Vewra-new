import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';

/// Heads-Up Display (HUD) overlay tracking server-authoritative playback duration and reward progress.
class TrackingHud extends StatelessWidget {
  final int currentSeconds;
  final int targetSeconds;
  final int rewardCoins;
  final bool isTracking;
  final bool quizRequired;
  final double? progressPercentage;

  const TrackingHud({
    super.key,
    required this.currentSeconds,
    required this.targetSeconds,
    required this.rewardCoins,
    this.isTracking = true,
    this.quizRequired = false,
    this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = progressPercentage != null
        ? (progressPercentage! / 100.0).clamp(0.0, 1.0)
        : (targetSeconds > 0
            ? (currentSeconds / targetSeconds).clamp(0.0, 1.0)
            : 0.0);

    final bool isCompleted = currentSeconds >= targetSeconds;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space16,
        vertical: AppConstants.space12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.success
                          : (isTracking
                              ? AppColors.successLight
                              : AppColors.warning),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCompleted
                        ? (quizRequired
                            ? 'Watch Completed (Quiz Next)'
                            : 'Watch Completed')
                        : (isTracking ? 'Server Tracking Active' : 'Tracking Paused'),
                    style: AppTypography.labelSmall.copyWith(
                      color: isCompleted
                          ? AppColors.success
                          : (isTracking
                              ? AppColors.successLight
                              : AppColors.warning),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.monetization_on_rounded,
                      color: AppColors.coinGold, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '+$rewardCoins Coins',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.coinGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.space8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? AppColors.success : AppColors.primaryLight,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.space6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${Formatters.formatTimer(currentSeconds)} / ${Formatters.formatTimer(targetSeconds)}',
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTypography.labelSmall.copyWith(
                  color: isCompleted ? AppColors.success : AppColors.primaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

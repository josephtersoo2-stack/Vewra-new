import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';

/// Heads-Up Display (HUD) overlay tracking playback duration and reward progress.
class TrackingHud extends StatelessWidget {
  final int currentSeconds;
  final int targetSeconds;
  final int rewardCoins;
  final bool isTracking;

  const TrackingHud({
    super.key,
    required this.currentSeconds,
    required this.targetSeconds,
    required this.rewardCoins,
    this.isTracking = true,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (currentSeconds / targetSeconds).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space16,
        vertical: AppConstants.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
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
                      color: isTracking ? AppColors.successLight : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isTracking ? 'Tracking Active' : 'Tracking Paused',
                    style: AppTypography.labelSmall.copyWith(
                      color: isTracking ? AppColors.successLight : AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, color: AppColors.coinGold, size: 14),
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
            borderRadius: AppConstants.borderRadiusFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
            ),
          ),
          const SizedBox(height: AppConstants.space6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${Formatters.formatTimer(currentSeconds)} / ${Formatters.formatTimer(targetSeconds)}',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryLight,
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

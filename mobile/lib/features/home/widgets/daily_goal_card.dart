import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/cards/app_card.dart';

/// Progress bar card tracking daily watch goal.
class DailyGoalCard extends StatelessWidget {
  final int completedTasks;
  final int targetTasks;
  final int minutesWatched;
  final int targetMinutes;

  const DailyGoalCard({
    super.key,
    this.completedTasks = 3,
    this.targetTasks = 5,
    this.minutesWatched = 18,
    this.targetMinutes = 30,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (completedTasks / targetTasks).clamp(0.0, 1.0);

    return AppCard(
      padding: const EdgeInsets.all(AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag_rounded, color: AppColors.secondary, size: 18),
                  const SizedBox(width: AppConstants.space8),
                  Text(
                    AppStrings.dailyGoal,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '$completedTasks / $targetTasks Tasks',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.space12),
          // Progress bar track
          ClipRRect(
            borderRadius: AppConstants.borderRadiusFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
            ),
          ),
          const SizedBox(height: AppConstants.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% completed',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '$minutesWatched min watched today',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

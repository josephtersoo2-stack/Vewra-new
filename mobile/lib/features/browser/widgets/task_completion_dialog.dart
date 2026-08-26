import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../models/watch_completion_model.dart';

/// Server-verified completion dialog displaying real credited coins and audit reference.
class TaskCompletionDialog extends StatelessWidget {
  final WatchCompletionModel result;
  final VoidCallback onDismiss;

  const TaskCompletionDialog({
    super.key,
    required this.result,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      contentPadding: const EdgeInsets.all(AppConstants.space24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.space16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: AppColors.coinGold,
              size: 48,
            ),
          ),
          const SizedBox(height: AppConstants.space16),
          Text(
            'Task Verified!',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.space8),
          Text(
            result.message.isNotEmpty
                ? result.message
                : 'Congratulations! Your watch duration has been verified.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.space16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.space16,
              vertical: AppConstants.space12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: AppColors.coinGold, size: 22),
                const SizedBox(width: 8),
                Text(
                  '+${result.rewardCoins} Coins Credited',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.coinGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (result.rewardReference != null) ...[
            const SizedBox(height: AppConstants.space10),
            Text(
              'Ref: ${result.rewardReference}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: AppConstants.space20),
          AppButton(
            text: 'Return to Earn',
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';

/// Reusable Reward Card for daily check-in rewards and streak items.
class RewardCard extends StatelessWidget {
  final int day;
  final int rewardCoins;
  final bool isClaimed;
  final bool isToday;
  final VoidCallback? onClaim;

  const RewardCard({
    super.key,
    required this.day,
    required this.rewardCoins,
    this.isClaimed = false,
    this.isToday = false,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.border;
    Color bgColor = AppColors.card;

    if (isToday && !isClaimed) {
      borderColor = AppColors.amber;
      bgColor = AppColors.amber.withValues(alpha: 0.12);
    } else if (isClaimed) {
      borderColor = AppColors.emerald.withValues(alpha: 0.4);
      bgColor = AppColors.emerald.withValues(alpha: 0.08);
    }

    return InkWell(
      onTap: isToday && !isClaimed ? onClaim : null,
      borderRadius: AppConstants.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.space12,
          vertical: AppConstants.space10,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppConstants.borderRadiusMd,
          border: Border.all(color: borderColor, width: isToday ? 1.5 : 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Day $day',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isToday ? AppColors.amber : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.space6),
            Icon(
              isClaimed
                  ? Icons.check_circle_rounded
                  : (isToday ? Icons.stars_rounded : Icons.monetization_on_outlined),
              size: 24,
              color: isClaimed
                  ? AppColors.emerald
                  : (isToday ? AppColors.amber : AppColors.textTertiary),
            ),
            const SizedBox(height: AppConstants.space6),
            Text(
              '+$rewardCoins',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isClaimed
                    ? AppColors.emerald
                    : (isToday ? AppColors.amber : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

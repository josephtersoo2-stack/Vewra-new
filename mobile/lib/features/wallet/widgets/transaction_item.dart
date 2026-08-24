import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/transaction_model.dart';
import '../../../core/widgets/cards/app_card.dart';

/// Reusable transaction list item representing earning, withdrawal, or bonus events.
class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (transaction.type) {
      case TransactionType.taskReward:
        icon = Icons.play_arrow_rounded;
        iconColor = AppColors.primaryLight;
        iconBg = AppColors.primary.withValues(alpha: 0.15);
        break;
      case TransactionType.dailyStreak:
        icon = Icons.local_fire_department_rounded;
        iconColor = AppColors.warning;
        iconBg = AppColors.warning.withValues(alpha: 0.15);
        break;
      case TransactionType.withdrawal:
        icon = Icons.arrow_outward_rounded;
        iconColor = AppColors.secondary;
        iconBg = AppColors.secondary.withValues(alpha: 0.15);
        break;
      case TransactionType.referralBonus:
        icon = Icons.group_add_rounded;
        iconColor = AppColors.successLight;
        iconBg = AppColors.success.withValues(alpha: 0.15);
        break;
    }

    final bool isPositive = transaction.isPositive;
    final String sign = isPositive ? '+' : '-';
    final Color amountColor = isPositive ? AppColors.successLight : AppColors.textPrimary;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppConstants.space12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.space10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppConstants.borderRadiusMd,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppConstants.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.timestamp),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${transaction.amountCoins} Coins',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$sign${Formatters.formatCurrency(transaction.amountFiat)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

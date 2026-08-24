import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../constants/app_constants.dart';
import 'app_card.dart';

/// Reusable metric card displaying key stat counters, title, and themed icons.
class AppMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final VoidCallback? onTap;

  const AppMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primaryLight;
    final effectiveIconBg = iconBgColor ?? effectiveIconColor.withValues(alpha: 0.15);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.space8),
                decoration: BoxDecoration(
                  color: effectiveIconBg,
                  borderRadius: AppConstants.borderRadiusSm,
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: AppConstants.iconSizeMd,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.labelSmall.copyWith(color: AppColors.successLight),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.space12),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.space4),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

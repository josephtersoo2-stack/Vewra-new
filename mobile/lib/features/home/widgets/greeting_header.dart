import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/buttons/app_icon_button.dart';
import '../../../models/user_model.dart';

/// Top header on the Home dashboard with avatar, greeting, and notification button.
class GreetingHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onNotificationsTap;

  const GreetingHeader({
    super.key,
    required this.user,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar with border
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            border: Border.all(color: AppColors.primaryLight, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.person_rounded, color: Colors.white, size: 26),
          ),
        ),
        const SizedBox(width: AppConstants.space12),
        // Greeting Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.greeting},',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                user.username,
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        // Streak Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            borderRadius: AppConstants.borderRadiusFull,
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 16),
              const SizedBox(width: 4),
              Text(
                '${user.streakDays}d',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.space8),
        AppIconButton(
          icon: Icons.notifications_none_rounded,
          iconSize: 20,
          size: 40,
          onPressed: onNotificationsTap,
        ),
      ],
    );
  }
}

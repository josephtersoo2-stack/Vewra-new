import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/buttons/app_icon_button.dart';
import '../../../models/user_model.dart';

/// Top header on the Home dashboard with avatar, greeting, streak badge, notifications, and menu button.
class GreetingHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onMenuTap;

  const GreetingHeader({
    super.key,
    required this.user,
    this.onNotificationsTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Side Menu Hamburger Button
        AppIconButton(
          icon: Icons.menu_rounded,
          iconSize: 22,
          size: 40,
          onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
        ),
        const SizedBox(width: AppConstants.space8),

        // Avatar with border
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            border: Border.all(color: AppColors.primaryLight, width: 1.5),
          ),
          child: ClipOval(
            child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                ? Image.network(
                    user.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, _) => const Center(
                      child: Icon(Icons.person_rounded, color: Colors.white, size: 22),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 22),
                  ),
          ),
        ),
        const SizedBox(width: AppConstants.space10),

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
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Streak Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            borderRadius: AppConstants.borderRadiusFull,
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 14),
              const SizedBox(width: 3),
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
        const SizedBox(width: AppConstants.space6),

        // Notifications Button
        AppIconButton(
          icon: Icons.notifications_none_rounded,
          iconSize: 20,
          size: 38,
          onPressed: onNotificationsTap,
        ),
      ],
    );
  }
}

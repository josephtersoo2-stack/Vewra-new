import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../constants/app_constants.dart';
import '../buttons/app_icon_button.dart';

/// Reusable top screen header with optional back button, menu button, title, subtitle, and custom action widgets.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showMenuButton;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.showMenuButton = false,
    this.onBack,
    this.onMenu,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space16,
        vertical: AppConstants.space8,
      ),
      child: Row(
        children: [
          if (showMenuButton) ...[
            AppIconButton(
              icon: Icons.menu_rounded,
              iconSize: 22,
              size: 40,
              onPressed: onMenu ?? () => Scaffold.of(context).openDrawer(),
            ),
            const SizedBox(width: AppConstants.space8),
          ],
          if (showBackButton) ...[
            AppIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              iconSize: 18,
              onPressed: onBack ?? () => Navigator.maybePop(context),
            ),
            const SizedBox(width: AppConstants.space12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppConstants.space2),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...?actions,
        ],
      ),
    );
  }
}

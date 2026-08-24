import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../constants/app_constants.dart';

enum AppButtonVariant { primary, secondary, outlined, ghost, danger }

/// Reusable primary button supporting various styles, loading state, and icons.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final double btnHeight = height ?? AppConstants.buttonHeight;
    final bool enabled = onPressed != null && !isLoading;

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.outlined || variant == AppButtonVariant.ghost
                ? AppColors.primary
                : Colors.white,
          ),
        ),
      );
    } else {
      childContent = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: AppConstants.space8),
          ],
          Text(
            text,
            style: AppTypography.labelLarge.copyWith(
              color: _getTextColor(enabled),
            ),
          ),
          if (suffixIcon != null) ...[
            const SizedBox(width: AppConstants.space8),
            suffixIcon!,
          ],
        ],
      );
    }

    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = Container(
          height: btnHeight,
          decoration: BoxDecoration(
            gradient: enabled ? AppColors.primaryGradient : null,
            color: enabled ? null : AppColors.surfaceLight,
            borderRadius: AppConstants.borderRadiusMd,
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              borderRadius: AppConstants.borderRadiusMd,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
                  child: childContent,
                ),
              ),
            ),
          ),
        );
        break;

      case AppButtonVariant.secondary:
        button = SizedBox(
          height: btnHeight,
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: AppConstants.borderRadiusMd,
                side: BorderSide(color: AppColors.border),
              ),
            ),
            child: childContent,
          ),
        );
        break;

      case AppButtonVariant.outlined:
        button = SizedBox(
          height: btnHeight,
          child: OutlinedButton(
            onPressed: enabled ? onPressed : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: enabled ? AppColors.primaryLight : AppColors.border,
                width: 1.5,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppConstants.borderRadiusMd,
              ),
            ),
            child: childContent,
          ),
        );
        break;

      case AppButtonVariant.ghost:
        button = SizedBox(
          height: btnHeight,
          child: TextButton(
            onPressed: enabled ? onPressed : null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
              shape: const RoundedRectangleBorder(
                borderRadius: AppConstants.borderRadiusMd,
              ),
            ),
            child: childContent,
          ),
        );
        break;

      case AppButtonVariant.danger:
        button = SizedBox(
          height: btnHeight,
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: AppConstants.borderRadiusMd,
              ),
            ),
            child: childContent,
          ),
        );
        break;
    }

    if (!isFullWidth) {
      return button;
    }

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }

  Color _getTextColor(bool enabled) {
    if (!enabled) return AppColors.textMuted;
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.secondary:
        return AppColors.textPrimary;
      case AppButtonVariant.outlined:
      case AppButtonVariant.ghost:
        return AppColors.primaryLight;
    }
  }
}

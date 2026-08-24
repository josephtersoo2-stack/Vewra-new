import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_strings.dart';
import '../buttons/app_button.dart';

/// Reusable error state view with error indicator, descriptive message, and retry button.
class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorState({
    super.key,
    this.title = AppStrings.errorTitle,
    this.message = AppStrings.errorDesc,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.space24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.errorLight,
              ),
            ),
            const SizedBox(height: AppConstants.space24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.space8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.space24),
              AppButton(
                text: AppStrings.retry,
                onPressed: onRetry,
                isFullWidth: false,
                prefixIcon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                variant: AppButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

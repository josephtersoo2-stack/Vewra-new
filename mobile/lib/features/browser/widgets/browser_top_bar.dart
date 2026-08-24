import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/buttons/app_icon_button.dart';

/// Top browser address bar with secure lock indicator, domain display, and quick actions.
class BrowserTopBar extends StatelessWidget {
  final String url;
  final VoidCallback? onClose;
  final VoidCallback? onReload;

  const BrowserTopBar({
    super.key,
    required this.url,
    this.onClose,
    this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space12,
        vertical: AppConstants.space8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.close_rounded,
            iconSize: 20,
            size: 36,
            onPressed: onClose ?? () => Navigator.pop(context),
          ),
          const SizedBox(width: AppConstants.space8),
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppConstants.borderRadiusSm,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, size: 14, color: AppColors.successLight),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppConstants.space8),
          AppIconButton(
            icon: Icons.refresh_rounded,
            iconSize: 18,
            size: 36,
            onPressed: onReload,
          ),
        ],
      ),
    );
  }
}

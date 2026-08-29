import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/campaign_media_model.dart';

class CampaignMediaCard extends StatelessWidget {
  final CampaignMediaModel media;
  final VoidCallback? onTap;
  final VoidCallback? onDisable;
  final VoidCallback? onRestore;
  final bool isManageable;

  const CampaignMediaCard({
    super.key,
    required this.media,
    this.onTap,
    this.onDisable,
    this.onRestore,
    this.isManageable = false,
  });

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'READY':
        return AppColors.emerald;
      case 'PROCESSING':
        return AppColors.warning;
      case 'DISABLED':
        return AppColors.error;
      case 'FAILED':
        return AppColors.error;
      case 'DRAFT':
      default:
        return AppColors.textTertiary;
    }
  }

  IconData _getTypeIcon(String mediaType) {
    switch (mediaType.toUpperCase()) {
      case 'VIDEO':
        return Icons.videocam_rounded;
      case 'BANNER':
        return Icons.view_compact_rounded;
      case 'IMAGE':
      default:
        return Icons.image_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(media.status);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Media Type & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTypeIcon(media.mediaType),
                      size: 14,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      media.mediaTypeDisplay,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  media.statusDisplay,
                  style: AppTypography.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.space12),

          // Title & Description
          Text(
            media.title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          if (media.description.isNotEmpty) ...[
            const SizedBox(height: AppConstants.space4),
            Text(
              media.description,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: AppConstants.space12),

          // Metadata Chips (Dimensions, File Size, Duration)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (media.dimensionsText.isNotEmpty)
                _buildMetaChip(
                  Icons.aspect_ratio_rounded,
                  media.dimensionsText,
                ),
              if (media.fileSizeFormatted.isNotEmpty)
                _buildMetaChip(
                  Icons.folder_open_rounded,
                  media.fileSizeFormatted,
                ),
              if (media.durationSeconds != null && media.durationSeconds! > 0)
                _buildMetaChip(
                  Icons.timer_outlined,
                  '${media.durationSeconds}s',
                ),
            ],
          ),

          // Management Actions (for Advertiser / Admin)
          if (isManageable) ...[
            const SizedBox(height: AppConstants.space12),
            const Divider(color: AppColors.border),
            const SizedBox(height: AppConstants.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!media.isDisabled && onDisable != null)
                  TextButton.icon(
                    onPressed: onDisable,
                    icon: const Icon(Icons.block_rounded, size: 16, color: AppColors.error),
                    label: Text(
                      'Disable Asset',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.error),
                    ),
                  )
                else if (media.isDisabled && onRestore != null)
                  TextButton.icon(
                    onPressed: onRestore,
                    icon: const Icon(Icons.restore_rounded, size: 16, color: AppColors.emerald),
                    label: Text(
                      'Restore Asset',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.emerald),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../models/gamification_model.dart';

/// Locked Feature Progression Card showing level, verification, and trust score unlock requirements.
class FeatureUnlockCard extends StatelessWidget {
  final FeatureUnlockModel unlock;
  final VoidCallback? onTap;

  const FeatureUnlockCard({
    super.key,
    required this.unlock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: unlock.isUnlocked ? AppCardVariant.standard : AppCardVariant.outlined,
      padding: const EdgeInsets.all(AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon, Name & Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.space8),
                decoration: BoxDecoration(
                  color: (unlock.isUnlocked ? AppColors.emerald : AppColors.primary)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  unlock.isUnlocked ? unlock.icon : Icons.lock_outline_rounded,
                  size: 20,
                  color: unlock.isUnlocked ? AppColors.emerald : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: AppConstants.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unlock.featureName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      unlock.description,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (unlock.isUnlocked ? AppColors.emerald : AppColors.surface)
                      .withValues(alpha: 0.2),
                  borderRadius: AppConstants.borderRadiusSm,
                  border: Border.all(
                    color: unlock.isUnlocked ? AppColors.emerald : AppColors.border,
                  ),
                ),
                child: Text(
                  unlock.isUnlocked ? 'UNLOCKED' : 'LOCKED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: unlock.isUnlocked ? AppColors.emerald : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.space12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppConstants.space10),

          // Unlock Requirements Checklist
          const Text(
            'Unlock Requirements:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              _buildReqPill(
                label: 'Level ${unlock.requiredLevel}',
                isMet: unlock.isLevelMet,
                current: 'LVL ${unlock.currentLevel}',
              ),
              const SizedBox(width: 6),
              _buildReqPill(
                label: unlock.requiredVerification,
                isMet: unlock.isUnlocked || unlock.currentVerification == 'Verified',
                current: unlock.currentVerification,
              ),
              const SizedBox(width: 6),
              _buildReqPill(
                label: '${unlock.requiredTrustScore}% Trust',
                isMet: unlock.isTrustMet,
                current: '${unlock.currentTrustScore}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReqPill({
    required String label,
    required bool isMet,
    required String current,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isMet ? AppColors.emerald.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: AppConstants.borderRadiusSm,
          border: Border.all(
            color: isMet ? AppColors.emerald.withValues(alpha: 0.4) : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 10,
                  color: isMet ? AppColors.emerald : AppColors.textTertiary,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isMet ? AppColors.emerald : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              current,
              style: const TextStyle(fontSize: 8, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

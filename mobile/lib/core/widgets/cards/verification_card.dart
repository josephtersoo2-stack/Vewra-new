import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';
import 'app_card.dart';

/// Reusable Verification Tier Card displaying level requirements, limits, and benefits.
class VerificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String withdrawalLimit;
  final List<String> requirements;
  final List<String> benefits;
  final bool isCurrent;
  final bool isUnlocked;
  final VoidCallback? onVerify;

  const VerificationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.withdrawalLimit,
    required this.requirements,
    required this.benefits,
    this.isCurrent = false,
    this.isUnlocked = false,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: isCurrent ? AppCardVariant.elevated : AppCardVariant.standard,
      padding: const EdgeInsets.all(AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tier Title, Subtitle, & Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.space8),
                decoration: BoxDecoration(
                  color: (isCurrent ? AppColors.primary : (isUnlocked ? AppColors.emerald : AppColors.surface))
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUnlocked ? Icons.verified_user_rounded : Icons.lock_outline_rounded,
                  size: 20,
                  color: isCurrent
                      ? AppColors.primaryLight
                      : (isUnlocked ? AppColors.emerald : AppColors.textTertiary),
                ),
              ),
              const SizedBox(width: AppConstants.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: AppConstants.borderRadiusSm,
                  ),
                  child: const Text(
                    'CURRENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryLight,
                    ),
                  ),
                )
              else if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.2),
                    borderRadius: AppConstants.borderRadiusSm,
                  ),
                  child: const Text(
                    'UNLOCKED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppConstants.space12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppConstants.space12),

          // Withdrawal Limit
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppConstants.space6),
              const Text(
                'Withdrawal Limit: ',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                withdrawalLimit,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.space10),

          // Requirements
          const Text(
            'Requirements:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.space4),
          ...requirements.map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Icon(
                    isUnlocked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 14,
                    color: isUnlocked ? AppColors.emerald : AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppConstants.space6),
                  Text(
                    req,
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),

          if (!isUnlocked && onVerify != null) ...[
            const SizedBox(height: AppConstants.space14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.space10),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppConstants.borderRadiusMd,
                  ),
                  elevation: 0,
                ),
                child: Text('Upgrade to $title'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

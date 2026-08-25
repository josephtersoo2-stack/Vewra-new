import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/layout/app_header.dart';
import '../../../core/widgets/cards/verification_card.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../services/dummy_data_service.dart';

/// Screen showcasing user Verification Status, Trust Score, and multi-tier upgrade requirements.
class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = DummyDataService.currentUser;

    return Scaffold(
      appBar: const AppHeader(
        title: 'Identity & Trust Score',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPaddingH,
          vertical: AppConstants.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trust Score Overview Card
            AppCard(
              variant: AppCardVariant.gradient,
              padding: const EdgeInsets.all(AppConstants.space16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.emerald, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${user.trustScore}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.space14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Trust Score: Excellent',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: AppConstants.space6),
                            const Icon(Icons.verified_rounded, size: 16, color: AppColors.cyan),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your account has strong watch verification history and high community reputation.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.space24),

            const Text(
              'Verification Levels & Privileges',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Higher verification tiers unlock higher monthly cashout limits and P2P marketplace selling.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),

            const SizedBox(height: AppConstants.space16),

            ...DummyDataService.verificationTiers.map(
              (tier) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.space12),
                child: VerificationCard(
                  title: tier.title,
                  subtitle: tier.subtitle,
                  withdrawalLimit: tier.withdrawalLimit,
                  requirements: tier.requirements,
                  benefits: tier.benefits,
                  isCurrent: tier.isCurrent,
                  isUnlocked: tier.isUnlocked,
                  onVerify: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primary,
                        content: Text('Starting document submission for ${tier.title} (Template)'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../providers/profile_provider.dart';
import '../models/subscription_model.dart';

/// Screen displaying subscription tiers, ecosystem benefits, and active membership.
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final currentTierName = profileState.user?.subscriptionTier.toUpperCase() ?? 'FREE';
    final plans = profileState.plans.isNotEmpty
        ? profileState.plans
        : [
            const SubscriptionTierModel(
              id: 1,
              name: 'FREE',
              slug: 'free',
              description: 'Standard access to daily rewards and content discovery.',
              monthlyPrice: 0.00,
              annualPrice: 0.00,
              benefits: [
                'Standard video reward rate (1x)',
                'Access to Community & Discussions',
                '1 Free Daily Spin Wheel',
                'Standard withdrawal limits',
              ],
            ),
            const SubscriptionTierModel(
              id: 2,
              name: 'PREMIUM',
              slug: 'premium',
              description: 'Enhanced earning rate, priority verification and exclusive perks.',
              monthlyPrice: 4.99,
              annualPrice: 49.99,
              benefits: [
                '2x Watch reward multiplier',
                'Priority KYC verification queue',
                '3 Daily Spin Wheel chances',
                '50% lower marketplace trading fees',
                'Exclusive Creator Quests',
              ],
            ),
            const SubscriptionTierModel(
              id: 3,
              name: 'PRO',
              slug: 'pro',
              description: 'Ultimate power tools, creator studio, and instant payouts.',
              monthlyPrice: 14.99,
              annualPrice: 149.99,
              benefits: [
                '3x Watch reward multiplier',
                'Instant verification approval',
                '5 Daily Spin Wheel chances',
                'Full Creator Studio & Campaign Hub',
                '0% marketplace redemption fees',
              ],
            ),
          ];

    return AppScaffold(
      appBar: AppBar(
        title: Text('Membership & Plans', style: AppTypography.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Summary Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.space20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.surfaceElevated],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppConstants.borderRadiusLg,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Membership',
                        style: AppTypography.labelMedium.copyWith(color: AppColors.primaryLight),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.2),
                          borderRadius: AppConstants.borderRadiusFull,
                          border: Border.all(color: AppColors.emerald),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.emerald,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.space8),
                  Text(
                    '$currentTierName Member',
                    style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppConstants.space4),
                  Text(
                    'Upgrade your plan anytime to unlock multiplied reward rates.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.space24),
            Text(
              'Available Plans',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppConstants.space16),

            ...plans.map((plan) {
              final isCurrent = plan.name.toUpperCase() == currentTierName;
              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.space16),
                child: AppCard(
                  border: BorderSide(
                    color: isCurrent ? AppColors.primary : AppColors.border,
                    width: isCurrent ? 2 : 1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan.name,
                            style: AppTypography.titleLarge.copyWith(
                              color: isCurrent ? AppColors.primaryLight : AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            plan.monthlyPrice == 0 ? 'FREE' : '\$${plan.monthlyPrice.toStringAsFixed(2)} / mo',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.emerald,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.space8),
                      Text(
                        plan.description,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      ...plan.benefits.map(
                        (benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primaryLight),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.space12),
                      if (isCurrent)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppConstants.borderRadiusMd,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            'Current Active Plan',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        AppButton(
                          text: 'Select ${plan.name}',
                          variant: AppButtonVariant.outlined,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Selected ${plan.name} Tier. Payment processing will be available in Phase 5.'),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppConstants.space24),
          ],
        ),
      ),
    );
  }
}

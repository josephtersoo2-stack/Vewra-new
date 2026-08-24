import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/layout/app_scaffold.dart';

/// Welcome / Onboarding screen showcasing the platform value proposition.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.space24),
        child: Column(
          children: [
            const SizedBox(height: AppConstants.space24),
            // Hero Brand Badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppConstants.space24),
            Text(
              AppStrings.welcomeTitle,
              textAlign: TextAlign.center,
              style: AppTypography.displayMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppConstants.space12),
            Text(
              AppStrings.welcomeSubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.space32),
            // Feature Highlights
            _buildFeatureTile(
              icon: Icons.video_library_rounded,
              iconColor: AppColors.primaryLight,
              title: 'Curated YouTube Content',
              desc: 'Discover verified videos across tech, gaming, and culture.',
            ),
            const SizedBox(height: AppConstants.space12),
            _buildFeatureTile(
              icon: Icons.timer_outlined,
              iconColor: AppColors.secondary,
              title: 'Automated Time Tracking',
              desc: 'Secure in-app engine verifies full watch time accurately.',
            ),
            const SizedBox(height: AppConstants.space12),
            _buildFeatureTile(
              icon: Icons.monetization_on_rounded,
              iconColor: AppColors.warning,
              title: 'Instant Coin Rewards',
              desc: 'Coins are directly deposited into your wallet balance.',
            ),
            const SizedBox(height: AppConstants.space32),
            // Actions
            AppButton(
              text: AppStrings.getStarted,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              variant: AppButtonVariant.primary,
            ),
            const SizedBox(height: AppConstants.space12),
            AppButton(
              text: AppStrings.login,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              variant: AppButtonVariant.secondary,
            ),
            const SizedBox(height: AppConstants.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space16,
        vertical: AppConstants.space12,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.space8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: AppConstants.borderRadiusSm,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppConstants.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  desc,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/cards/level_progress_card.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';
import 'subscription_screen.dart';

/// User Profile Screen with level progress, verification status, trust score, and account management.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: AppConstants.borderRadiusLg,
          side: BorderSide(color: AppColors.border),
        ),
        title: Text(AppStrings.logout, style: AppTypography.headlineSmall),
        content: Text(
          AppStrings.logoutConfirm,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.welcome,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final user = profileState.user ??
        ref.watch(authProvider).user ??
        const UserModel(
          id: 'usr_default',
          username: 'alex_developer',
          email: 'alex.dev@vewra.io',
          displayName: 'Alex Developer',
          level: 14,
          xp: 2450,
          xpNextLevel: 3000,
          trustScore: 96,
          verificationStatus: 'Verified',
          subscriptionTier: 'Premium',
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.space12),
          Text(
            AppStrings.profile,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppConstants.space20),

          // 1. Profile Top Header
          ProfileHeader(
            user: user,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),

          const SizedBox(height: AppConstants.space16),

          // 2. Level, XP & Trust Score Progress Card
          LevelProgressCard(
            level: user.level,
            currentXp: user.xp,
            nextLevelXp: user.xpNextLevel,
            trustScore: user.trustScore,
            verificationStatus: user.verificationStatus,
            onTap: () => Navigator.pushNamed(context, AppRoutes.verification),
          ),

          const SizedBox(height: AppConstants.space20),

          // 3. Verification & Trust Score Tile
          ProfileMenuItem(
            icon: Icons.verified_user_rounded,
            iconColor: AppColors.cyan,
            title: 'Verification & Trust Score',
            subtitle: '${user.verificationStatus} Tier • Trust Score: ${user.trustScore}%',
            onTap: () => Navigator.pushNamed(context, AppRoutes.verification),
          ),

          const SizedBox(height: AppConstants.space10),

          // 4. Subscription Plan Tile
          ProfileMenuItem(
            icon: Icons.workspace_premium_rounded,
            iconColor: AppColors.amber,
            title: 'Subscription Tier',
            subtitle: '${user.subscriptionTier} Member • Manage Benefits',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
          ),

          const SizedBox(height: AppConstants.space10),

          // 5. Digital Marketplace Shortcut
          ProfileMenuItem(
            icon: Icons.storefront_rounded,
            iconColor: AppColors.emerald,
            title: 'Marketplace & Redemptions',
            subtitle: 'Airtime, Gift Cards, P2P Coin trades',
            onTap: () => Navigator.pushNamed(context, AppRoutes.marketplace),
          ),

          const SizedBox(height: AppConstants.space10),

          // 6. Community Hub Shortcut
          ProfileMenuItem(
            icon: Icons.groups_rounded,
            iconColor: AppColors.primaryLight,
            title: 'Community & Discussions',
            subtitle: 'Connect with creators and top earners',
            onTap: () => Navigator.pushNamed(context, AppRoutes.community),
          ),

          const SizedBox(height: AppConstants.space10),

          // 7. Payment Methods
          ProfileMenuItem(
            icon: Icons.payment_rounded,
            iconColor: AppColors.secondary,
            title: AppStrings.paymentMethods,
            subtitle: 'USDT Crypto, PayPal, ACH Bank Wire',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment preferences: USDT Crypto & PayPal connected')),
              );
            },
          ),

          const SizedBox(height: AppConstants.space10),

          // 8. Refer a Friend
          ProfileMenuItem(
            icon: Icons.card_giftcard_rounded,
            iconColor: AppColors.warning,
            title: AppStrings.referFriend,
            subtitle: 'Earn +500 Coins for every invited friend',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referral code copied: VEWRA-ALEX-2026')),
              );
            },
          ),

          const SizedBox(height: AppConstants.space10),

          // 9. App Settings
          ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: AppStrings.settings,
            subtitle: 'App preferences, notifications, security',
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),

          const SizedBox(height: AppConstants.space10),

          // 10. Help & Support
          ProfileMenuItem(
            icon: Icons.help_outline_rounded,
            title: AppStrings.helpSupport,
            subtitle: 'FAQ, guidelines, and contact support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('VEWRA Support: support@vewra.io')),
              );
            },
          ),

          const SizedBox(height: AppConstants.space10),

          // 11. Logout
          ProfileMenuItem(
            icon: Icons.logout_rounded,
            iconColor: AppColors.error,
            title: AppStrings.logout,
            subtitle: 'Sign out of your account on this device',
            onTap: () => _showLogoutDialog(context, ref),
          ),
          const SizedBox(height: AppConstants.space32),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../../services/dummy_data_service.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

/// User Profile Screen with stats, account shortcuts, and settings navigation.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: AppConstants.borderRadiusLg,
          side: BorderSide(color: AppColors.border),
        ),
        title: Text('Edit Profile', style: AppTypography.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: DummyDataService.currentUser.username),
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: DummyDataService.currentUser.email),
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile changes saved!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.welcome,
                (route) => false,
              );
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
  Widget build(BuildContext context) {
    final user = DummyDataService.currentUser;

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
          // Profile Top Header
          ProfileHeader(
            user: user,
            onEdit: () => _showEditProfile(context),
          ),
          const SizedBox(height: AppConstants.space24),
          // Menu Items
          ProfileMenuItem(
            icon: Icons.person_outline_rounded,
            title: AppStrings.editProfile,
            subtitle: 'Update username, avatar, and contact info',
            onTap: () => _showEditProfile(context),
          ),
          const SizedBox(height: AppConstants.space10),
          ProfileMenuItem(
            icon: Icons.payment_rounded,
            iconColor: AppColors.secondary,
            title: AppStrings.paymentMethods,
            subtitle: 'PayPal, ACH Bank Wire, Gift Cards',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment preferences: PayPal connected')),
              );
            },
          ),
          const SizedBox(height: AppConstants.space10),
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
          ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: AppStrings.settings,
            subtitle: 'App preferences, notifications, security',
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          const SizedBox(height: AppConstants.space10),
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
          ProfileMenuItem(
            icon: Icons.logout_rounded,
            iconColor: AppColors.error,
            title: AppStrings.logout,
            subtitle: 'Sign out of your account on this device',
            onTap: () => _showLogoutDialog(context),
          ),
          const SizedBox(height: AppConstants.space32),
        ],
      ),
    );
  }
}

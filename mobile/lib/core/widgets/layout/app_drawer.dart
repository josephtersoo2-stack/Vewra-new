import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_strings.dart';
import '../../routing/app_routes.dart';
import '../../../services/dummy_data_service.dart';

/// Comprehensive Side Navigation Drawer for VEWRA Ecosystem Modules.
class AppDrawer extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const AppDrawer({
    super.key,
    this.onNavigateTab,
  });

  void _showFeatureModal(BuildContext context, {required String title, required String description, required IconData icon}) {
    Navigator.pop(context); // Close drawer
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppConstants.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.space10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: AppConstants.borderRadiusMd,
                  ),
                  child: Icon(icon, size: 24, color: AppColors.primaryLight),
                ),
                const SizedBox(width: AppConstants.space12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.space16),
            Text(
              description,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: AppConstants.space24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.space12),
                  shape: RoundedRectangleBorder(borderRadius: AppConstants.borderRadiusMd),
                ),
                child: const Text('Got it'),
              ),
            ),
            const SizedBox(height: AppConstants.space16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Navigator.pop(context); // Close drawer
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

    return Drawer(
      backgroundColor: AppColors.backgroundSecondary,
      child: Column(
        children: [
          // 1. Drawer Header: User Profile Summary
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.space16,
              50,
              AppConstants.space16,
              AppConstants.space16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded, size: 14, color: AppColors.cyan),
                            ],
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.space12),
                // Level & Trust Score Pills
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: AppConstants.borderRadiusSm,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'LVL ${user.level}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.15),
                        borderRadius: AppConstants.borderRadiusSm,
                        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'Trust: ${user.trustScore}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emerald,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.15),
                        borderRadius: AppConstants.borderRadiusSm,
                        border: Border.all(color: AppColors.amber.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        user.subscriptionTier,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Drawer Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.space8),
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile',
                  subtitle: 'Account details & security',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigateTab?.call(4);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.military_tech_rounded,
                  iconColor: AppColors.primaryLight,
                  title: 'Level & Achievements',
                  subtitle: 'XP progress, ranks, badges',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigateTab?.call(2);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.verified_user_rounded,
                  iconColor: AppColors.cyan,
                  title: 'Verification',
                  subtitle: 'Identity tiers & cashout limits',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.verification);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.storefront_rounded,
                  iconColor: AppColors.emerald,
                  title: 'Marketplace',
                  subtitle: 'Airtime, Gift Cards, Digital goods',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.marketplace);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.currency_exchange_rounded,
                  iconColor: AppColors.amber,
                  title: 'Coin Exchange',
                  subtitle: 'P2P Escrow trade market',
                  onTap: () => _showFeatureModal(
                    context,
                    title: 'P2P Coin Exchange',
                    description: 'Trade VEWRA Coins directly with verified users worldwide. Automated smart escrow protects both buyer and seller.',
                    icon: Icons.currency_exchange_rounded,
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.groups_rounded,
                  iconColor: AppColors.primaryLight,
                  title: 'Community',
                  subtitle: 'Discussions, tips, earner posts',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.community);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.video_library_rounded,
                  iconColor: Colors.redAccent,
                  title: 'Creator Hub',
                  subtitle: 'Launch video promotion campaigns',
                  onTap: () => _showFeatureModal(
                    context,
                    title: 'VEWRA Creator Hub',
                    description: 'Promote your YouTube videos to thousands of verified real human viewers. Set custom watch durations, target regions, and monitor retention analytics in real-time.',
                    icon: Icons.video_library_rounded,
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.emoji_events_rounded,
                  iconColor: AppColors.amber,
                  title: 'Promotions & Tournaments',
                  subtitle: 'Weekly \$500 prize competitions',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigateTab?.call(2);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: AppColors.amber,
                  title: 'Subscriptions',
                  subtitle: 'VIP multiplier & zero-fee perks',
                  onTap: () => _showFeatureModal(
                    context,
                    title: 'VIP Subscriptions',
                    description: 'Upgrade to VEWRA Pro (\$4.99/mo) for 1.5x coin earnings, priority payouts, zero withdrawal fees, and exclusive tournament entry.',
                    icon: Icons.workspace_premium_rounded,
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.smart_toy_rounded,
                  iconColor: AppColors.cyan,
                  title: 'AI Assistant',
                  subtitle: 'Earning strategies & guidance',
                  onTap: () => _showFeatureModal(
                    context,
                    title: 'VEWRA AI Assistant',
                    description: 'Ask the VEWRA AI Assistant for personalized earning tips, highest paying daily video categories, and verification guidelines.',
                    icon: Icons.smart_toy_rounded,
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.card_giftcard_rounded,
                  iconColor: AppColors.warning,
                  title: 'Referral Program',
                  subtitle: 'Earn +500 Coins per invited user',
                  onTap: () => _showFeatureModal(
                    context,
                    title: 'Referral Program',
                    description: 'Share your personal referral link or code (VEWRA-ALEX-2026). When friends join and complete their first task, you both earn +500 bonus coins!',
                    icon: Icons.card_giftcard_rounded,
                  ),
                ),

                const Divider(color: AppColors.border, height: 20),

                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Preferences, security, notifications',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'FAQ, guidelines, contact desk',
                  onTap: () => _showFeatureModal(
                    context,
                    title: 'Help & Support',
                    description: 'Need assistance? Reach our 24/7 support desk at support@vewra.io or check our detailed community guidelines.',
                    icon: Icons.help_outline_rounded,
                  ),
                ),
              ],
            ),
          ),

          // 3. Drawer Footer: Version & Logout
          Container(
            padding: const EdgeInsets.all(AppConstants.space16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VEWRA Ecosystem',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      'v1.0.0 (Foundation)',
                      style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  onPressed: () => _showLogoutDialog(context),
                  tooltip: 'Log Out',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppConstants.space8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.textSecondary).withValues(alpha: 0.12),
          borderRadius: AppConstants.borderRadiusSm,
        ),
        child: Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
      ),
      dense: true,
      onTap: onTap,
    );
  }
}

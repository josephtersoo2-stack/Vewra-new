import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/layout/app_header.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

/// Settings and user preferences screen.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _soundEffects = true;
  bool _darkMode = true;
  bool _biometricLogin = false;

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: AppConstants.borderRadiusLg,
          side: BorderSide(color: AppColors.border),
        ),
        title: Text('Change Password', style: AppTypography.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current Password'),
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
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
                const SnackBar(content: Text('Password updated successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
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
    return AppScaffold(
      body: Column(
        children: [
          const AppHeader(
            title: AppStrings.settings,
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.space12),
                  // Preferences Section
                  SettingsSection(
                    title: AppStrings.preferences,
                    children: [
                      SettingsTile(
                        icon: Icons.notifications_active_outlined,
                        title: AppStrings.pushNotifications,
                        subtitle: 'Alerts for high-reward tasks and payout status',
                        trailing: Switch(
                          value: _pushNotifications,
                          onChanged: (val) => setState(() => _pushNotifications = val),
                          activeTrackColor: AppColors.primaryLight,
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.volume_up_outlined,
                        title: AppStrings.soundEffects,
                        subtitle: 'Audio cues on reward claims and milestone progress',
                        trailing: Switch(
                          value: _soundEffects,
                          onChanged: (val) => setState(() => _soundEffects = val),
                          activeTrackColor: AppColors.primaryLight,
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: AppStrings.darkMode,
                        subtitle: 'Modern high-contrast dark palette (Recommended)',
                        trailing: Switch(
                          value: _darkMode,
                          onChanged: (val) => setState(() => _darkMode = val),
                          activeTrackColor: AppColors.primaryLight,
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.space24),
                  // Security Section
                  SettingsSection(
                    title: AppStrings.security,
                    children: [
                      SettingsTile(
                        icon: Icons.fingerprint_rounded,
                        title: AppStrings.biometricLogin,
                        subtitle: 'Face ID or Fingerprint authentication',
                        trailing: Switch(
                          value: _biometricLogin,
                          onChanged: (val) => setState(() => _biometricLogin = val),
                          activeTrackColor: AppColors.primaryLight,
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.lock_reset_rounded,
                        title: AppStrings.changePassword,
                        subtitle: 'Update your account login credentials',
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
                        onTap: _showChangePasswordDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.space24),
                  // Legal Section
                  SettingsSection(
                    title: AppStrings.legal,
                    children: [
                      SettingsTile(
                        icon: Icons.description_outlined,
                        title: AppStrings.termsOfService,
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening VEWRA Terms of Service...')),
                          );
                        },
                      ),
                      SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: AppStrings.privacyPolicy,
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening VEWRA Privacy Policy...')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.space24),
                  // App Version Info
                  Center(
                    child: Text(
                      'VEWRA v${AppConstants.appVersion} • Phase 1 UI/UX Foundation',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.space24),
                  // Logout Button
                  AppButton(
                    text: AppStrings.logout,
                    variant: AppButtonVariant.danger,
                    prefixIcon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                    onPressed: _handleLogout,
                  ),
                  const SizedBox(height: AppConstants.space32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

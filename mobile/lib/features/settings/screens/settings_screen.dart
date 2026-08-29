import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/layout/app_header.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../../../core/services/biometric_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

/// Settings and user preferences screen with live Theme and Biometric controls.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _biometricService = BiometricService();
  bool _pushNotifications = true;
  bool _soundEffects = true;
  bool _biometricLogin = false;
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final available = await _biometricService.isBiometricsAvailable();
    final hasCreds = await _biometricService.hasSavedCredentials();
    if (mounted) {
      setState(() {
        _biometricsAvailable = available;
        _biometricLogin = hasCreds;
      });
    }
  }

  Future<void> _handleBiometricToggle(bool enable) async {
    if (enable) {
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate using biometrics to enable Biometric Login',
      );

      if (!authenticated) {
        if (mounted) setState(() => _biometricLogin = false);
        return;
      }

      // Save credentials for the current logged-in user
      final authUser = ref.read(authProvider).user;
      final email = authUser?.email ?? 'josephtersoo@gmail.com';
      await _biometricService.saveBiometricCredentials(
        email: email,
        password: 'Liestics2.@',
      );

      if (mounted) {
        setState(() => _biometricLogin = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.emerald,
            content: Text('✓ Biometric login enabled successfully!'),
          ),
        );
      }
    } else {
      await _biometricService.clearBiometricCredentials();
      if (mounted) {
        setState(() => _biometricLogin = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Biometric login disabled.'),
          ),
        );
      }
    }
  }

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
                AppRoutes.login,
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
    final currentTheme = ref.watch(themeModeProvider);
    final isDarkMode = currentTheme == ThemeMode.dark;

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
                        icon: isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        title: isDarkMode ? 'Dark Mode' : 'Light Mode',
                        subtitle: isDarkMode
                            ? 'Sleek dark theme with neon accents'
                            : 'Clean bright daylight theme',
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (val) {
                            ref.read(themeModeProvider.notifier).toggleTheme(val);
                          },
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
                        subtitle: _biometricsAvailable
                            ? (_biometricLogin
                                ? 'Enabled — Face ID / Fingerprint ready'
                                : 'Disabled — Tap to enable quick login')
                            : 'Biometrics unavailable on this hardware',
                        trailing: Switch(
                          value: _biometricLogin,
                          onChanged: _biometricsAvailable ? _handleBiometricToggle : null,
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

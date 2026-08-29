import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../../../core/services/biometric_service.dart';
import '../widgets/auth_header.dart';
import '../providers/auth_provider.dart';

/// User login screen integrated with Riverpod authentication provider and Biometric authentication.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'josephtersoo@gmail.com');
  final _passwordController = TextEditingController(text: 'Liestics2.@');
  final _biometricService = BiometricService();
  bool _isLoading = false;
  bool _canUseBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isBiometricsAvailable();
    if (mounted) {
      setState(() => _canUseBiometrics = available);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await ref.read(authProvider.notifier).login(
        email: email,
        password: password,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        // Save credentials for future biometric logins
        await _biometricService.saveBiometricCredentials(
          email: email,
          password: password,
        );

        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainShell,
          (route) => false,
        );
      } else {
        final authState = ref.read(authProvider);
        final errorMessage = authState.errorMessage ?? 'Login failed. Please check your credentials.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(errorMessage),
          ),
        );
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    final authenticated = await _biometricService.authenticate(
      reason: 'Authenticate using biometrics to sign in to your Vewra account',
    );

    if (!authenticated || !mounted) return;

    final creds = await _biometricService.getSavedCredentials();
    if (creds != null) {
      setState(() => _isLoading = true);
      final success = await ref.read(authProvider.notifier).login(
        email: creds['email']!,
        password: creds['password']!,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainShell,
          (route) => false,
        );
        return;
      }
    }

    // Fallback: If no saved credentials yet, use current filled values if valid
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() => _isLoading = true);
      final success = await ref.read(authProvider.notifier).login(
        email: email,
        password: password,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        await _biometricService.saveBiometricCredentials(email: email, password: password);
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainShell,
          (route) => false,
        );
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.warning,
        content: Text('Please log in with password once to enable quick Biometric login.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.space24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppConstants.space16),
              const AuthHeader(
                title: 'Welcome Back',
                subtitle: 'Enter your credentials to access your reward dashboard.',
              ),
              const SizedBox(height: AppConstants.space32),
              AppTextField(
                key: const Key('login_email_field'),
                label: AppStrings.email,
                hint: AppStrings.emailPlaceholder,
                controller: _emailController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppConstants.space20),
              AppTextField(
                key: const Key('login_password_field'),
                label: AppStrings.password,
                hint: AppStrings.passwordPlaceholder,
                controller: _passwordController,
                validator: Validators.password,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppConstants.space12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                  child: Text(
                    AppStrings.forgotPassword,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.space20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      key: const Key('login_submit_button'),
                      text: AppStrings.login,
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),
                  ),
                  if (_canUseBiometrics) ...[
                    const SizedBox(width: AppConstants.space12),
                    InkWell(
                      onTap: _isLoading ? null : _handleBiometricLogin,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      child: Container(
                        height: 52,
                        width: 54,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          size: 30,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppConstants.space32),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.register),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
import '../widgets/auth_header.dart';
import '../providers/auth_provider.dart';

/// User login screen integrated with Riverpod authentication provider.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'alex.dev@vewra.io');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;

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
              const SizedBox(height: AppConstants.space24),
              AppButton(
                key: const Key('login_submit_button'),
                text: AppStrings.login,
                onPressed: _handleLogin,
                isLoading: _isLoading,
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
              const SizedBox(height: AppConstants.space24),
            ],
          ),
        ),
      ),
    );
  }
}

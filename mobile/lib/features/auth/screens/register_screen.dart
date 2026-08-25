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

/// User registration / account creation screen integrated with Riverpod authProvider.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreeTerms = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to terms and privacy policy to continue.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final email = _emailController.text.trim();
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      final success = await ref.read(authProvider.notifier).register(
        email: email,
        username: username,
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
        final errorMsg = authState.errorMessage ?? 'Registration failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(errorMsg),
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
                title: 'Create Account',
                subtitle: 'Join VEWRA to start earning verified content rewards.',
              ),
              const SizedBox(height: AppConstants.space32),
              AppTextField(
                key: const Key('register_username_field'),
                label: AppStrings.username,
                hint: AppStrings.usernamePlaceholder,
                controller: _usernameController,
                validator: Validators.username,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppConstants.space16),
              AppTextField(
                key: const Key('register_email_field'),
                label: AppStrings.email,
                hint: AppStrings.emailPlaceholder,
                controller: _emailController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppConstants.space16),
              AppTextField(
                key: const Key('register_password_field'),
                label: AppStrings.password,
                hint: AppStrings.passwordPlaceholder,
                controller: _passwordController,
                validator: Validators.password,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppConstants.space16),
              AppTextField(
                key: const Key('register_confirm_password_field'),
                label: AppStrings.confirmPassword,
                hint: AppStrings.passwordPlaceholder,
                controller: _confirmPasswordController,
                validator: (val) => Validators.confirmPassword(val, _passwordController.text),
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppConstants.space16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.agreeTerms,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.space24),
              AppButton(
                key: const Key('register_submit_button'),
                text: AppStrings.register,
                onPressed: _handleRegister,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppConstants.space24),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Log In',
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

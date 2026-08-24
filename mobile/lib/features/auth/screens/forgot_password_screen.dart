import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/buttons/app_icon_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/app_scaffold.dart';

/// Password recovery screen.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSubmitted = true;
          });
        }
      });
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
              AppIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                iconSize: 18,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppConstants.space24),
              Text(
                AppStrings.forgotPasswordTitle,
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppConstants.space8),
              Text(
                AppStrings.forgotPasswordSubtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.space32),
              if (_isSubmitted) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.space16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: AppConstants.borderRadiusMd,
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.successLight),
                      const SizedBox(width: AppConstants.space12),
                      Expanded(
                        child: Text(
                          AppStrings.resetLinkSent,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.space24),
                AppButton(
                  text: 'Back to Log In',
                  onPressed: () => Navigator.pop(context),
                  variant: AppButtonVariant.secondary,
                ),
              ] else ...[
                AppTextField(
                  key: const Key('forgot_password_email_field'),
                  label: AppStrings.email,
                  hint: AppStrings.emailPlaceholder,
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.textTertiary),
                ),
                const SizedBox(height: AppConstants.space24),
                AppButton(
                  key: const Key('forgot_password_submit_button'),
                  text: AppStrings.sendResetLink,
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

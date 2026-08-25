import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../providers/profile_provider.dart';

/// Screen allowing the user to edit their ecosystem profile information.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _languageController;
  late final TextEditingController _currencyController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider).user;
    _displayNameController = TextEditingController(text: user?.displayName ?? user?.username ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _countryController = TextEditingController(text: user?.country ?? 'Global');
    _cityController = TextEditingController(text: user?.city ?? '');
    _languageController = TextEditingController(text: user?.language ?? 'en');
    _currencyController = TextEditingController(text: user?.currency ?? 'USD');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _languageController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final success = await ref.read(profileProvider.notifier).updateProfile(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        language: _languageController.text.trim(),
        currency: _currencyController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.emerald,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(profileProvider).errorMessage ?? 'Failed to update profile';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTypography.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.space16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Identity',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppConstants.space8),
              Text(
                'Customize how you appear across the VEWRA ecosystem.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppConstants.space24),

              AppTextField(
                key: const Key('edit_display_name_field'),
                label: 'Display Name',
                hint: 'Enter your public display name',
                controller: _displayNameController,
                prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppConstants.space16),

              AppTextField(
                key: const Key('edit_bio_field'),
                label: 'Bio',
                hint: 'Tell the community about yourself',
                controller: _bioController,
                maxLines: 3,
                prefixIcon: const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppConstants.space16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      key: const Key('edit_country_field'),
                      label: 'Country',
                      hint: 'e.g. Canada',
                      controller: _countryController,
                      prefixIcon: const Icon(Icons.public_rounded, size: 20, color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(width: AppConstants.space12),
                  Expanded(
                    child: AppTextField(
                      key: const Key('edit_city_field'),
                      label: 'City',
                      hint: 'e.g. Toronto',
                      controller: _cityController,
                      prefixIcon: const Icon(Icons.location_city_rounded, size: 20, color: AppColors.textTertiary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.space16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      key: const Key('edit_currency_field'),
                      label: 'Currency',
                      hint: 'USD, EUR, CAD, NGN',
                      controller: _currencyController,
                      prefixIcon: const Icon(Icons.attach_money_rounded, size: 20, color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(width: AppConstants.space12),
                  Expanded(
                    child: AppTextField(
                      key: const Key('edit_language_field'),
                      label: 'Language',
                      hint: 'en, es, fr',
                      controller: _languageController,
                      prefixIcon: const Icon(Icons.language_rounded, size: 20, color: AppColors.textTertiary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.space32),
              AppButton(
                key: const Key('save_profile_button'),
                text: 'Save Changes',
                onPressed: _handleSave,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppConstants.space24),
            ],
          ),
        ),
      ),
    );
  }
}

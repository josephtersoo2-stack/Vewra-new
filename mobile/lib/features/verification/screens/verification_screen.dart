import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/layout/app_header.dart';
import '../../../core/widgets/cards/verification_card.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../services/dummy_data_service.dart';
import '../../profile/providers/profile_provider.dart';

/// Screen showcasing user Verification Status, Trust Score, and KYC document submission.
class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  void _showDocumentSubmissionModal(BuildContext context, String tierTitle) {
    final countryController = TextEditingController(text: 'Global');
    final docNumberController = TextEditingController();
    String selectedDocType = 'NATIONAL_ID';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: AppConstants.space24,
            right: AppConstants.space24,
            top: AppConstants.space24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppConstants.space24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Submit Verification ID',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Submit your identification details for $tierTitle verification.',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppConstants.space20),

              AppTextField(
                label: 'Issuing Country',
                hint: 'e.g. United States, Canada, Nigeria',
                controller: countryController,
              ),
              const SizedBox(height: AppConstants.space16),

              const Text(
                'Document Type',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedDocType,
                dropdownColor: AppColors.surfaceElevated,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: AppConstants.borderRadiusMd,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'NATIONAL_ID', child: Text('National Identity Card')),
                  DropdownMenuItem(value: 'PASSPORT', child: Text('International Passport')),
                  DropdownMenuItem(value: 'DRIVERS_LICENSE', child: Text("Driver's License")),
                  DropdownMenuItem(value: 'UTILITY_BILL', child: Text('Utility Bill (Address Proof)')),
                ],
                onChanged: (val) => setModalState(() => selectedDocType = val ?? 'NATIONAL_ID'),
              ),
              const SizedBox(height: AppConstants.space16),

              AppTextField(
                label: 'Document ID / Number',
                hint: 'Enter identification reference number',
                controller: docNumberController,
              ),
              const SizedBox(height: AppConstants.space24),

              AppButton(
                text: 'Submit for Review',
                isLoading: isSubmitting,
                onPressed: () async {
                  if (docNumberController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid document number.')),
                    );
                    return;
                  }

                  setModalState(() => isSubmitting = true);
                  final success = await ref.read(profileProvider.notifier).submitVerification(
                    country: countryController.text.trim(),
                    documentType: selectedDocType,
                    documentReference: docNumberController.text.trim(),
                  );

                  if (!context.mounted) return;
                  Navigator.pop(ctx);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verification documents submitted for review!'),
                        backgroundColor: AppColors.emerald,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final user = profileState.user ?? DummyDataService.currentUser;
    final verification = profileState.verification;

    return Scaffold(
      appBar: const AppHeader(
        title: 'Identity & Trust Score',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPaddingH,
          vertical: AppConstants.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trust Score Overview Card
            AppCard(
              variant: AppCardVariant.gradient,
              padding: const EdgeInsets.all(AppConstants.space16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.emerald, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${user.trustScore}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.space14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Trust Score: ${user.trustScore >= 80 ? "Excellent" : "Good"}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: AppConstants.space6),
                            const Icon(Icons.verified_rounded, size: 16, color: AppColors.cyan),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          verification?.isPending ?? false
                              ? 'Verification submitted! Your identity review is in progress.'
                              : 'Your account has strong watch verification history and high community reputation.',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.space24),

            const Text(
              'Verification Levels & Privileges',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Higher verification tiers unlock higher monthly cashout limits and P2P marketplace selling.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),

            const SizedBox(height: AppConstants.space16),

            ...DummyDataService.verificationTiers.map(
              (tier) {
                final isCurrentTier = user.verificationStatus.toLowerCase().contains(tier.title.toLowerCase()) ||
                    (tier.title == 'Basic' && user.verificationStatus == 'Basic');
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.space12),
                  child: VerificationCard(
                    title: tier.title,
                    subtitle: tier.subtitle,
                    withdrawalLimit: tier.withdrawalLimit,
                    requirements: tier.requirements,
                    benefits: tier.benefits,
                    isCurrent: isCurrentTier,
                    isUnlocked: tier.isUnlocked,
                    onVerify: () => _showDocumentSubmissionModal(context, tier.title),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

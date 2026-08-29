import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/user_model.dart';
import '../providers/profile_provider.dart';

/// Top profile card with user avatar, profile image upload, tier badge, and quick stats.
class ProfileHeader extends ConsumerWidget {
  final UserModel user;
  final VoidCallback? onEdit;

  const ProfileHeader({
    super.key,
    required this.user,
    this.onEdit,
  });

  Future<void> _handlePickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppConstants.space20),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXl)),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.space16),
            Text(
              'Change Profile Picture',
              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppConstants.space16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.primaryLight),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                  maxWidth: 800,
                );
                if (picked != null) {
                  final success = await ref.read(profileProvider.notifier).uploadAvatar(picked.path);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: success ? AppColors.emerald : AppColors.error,
                        content: Text(success ? 'Profile picture updated successfully!' : 'Failed to update avatar.'),
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.cyan),
              ),
              title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                  maxWidth: 800,
                );
                if (picked != null) {
                  final success = await ref.read(profileProvider.notifier).uploadAvatar(picked.path);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: success ? AppColors.emerald : AppColors.error,
                        content: Text(success ? 'Profile picture updated successfully!' : 'Failed to update avatar.'),
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: AppConstants.space12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarUrl = user.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return Column(
      children: [
        Stack(
          children: [
            InkWell(
              onTap: () => _handlePickImage(context, ref),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  border: Border.all(color: AppColors.primaryLight, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: hasAvatar
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, _) => const Center(
                            child: Icon(Icons.person_rounded, color: Colors.white, size: 50),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.person_rounded, color: Colors.white, size: 50),
                        ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: () => _handlePickImage(context, ref),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.space16),
        Text(
          user.username,
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppConstants.space4),
        Text(
          user.email,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.space12),
        // Membership Tier Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.coinGold.withValues(alpha: 0.15),
            borderRadius: AppConstants.borderRadiusFull,
            border: Border.all(color: AppColors.coinGold.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.coinGold, size: 16),
              const SizedBox(width: 6),
              Text(
                user.membershipTier,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.coinGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.space24),
        // Quick Stats Row
        Container(
          padding: const EdgeInsets.all(AppConstants.space16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppConstants.borderRadiusLg,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildStatItem('Tasks Done', '${user.tasksCompleted}', Icons.task_alt_rounded),
              _buildDivider(),
              _buildStatItem('Watched', '${user.totalMinutesWatched}m', Icons.timer_outlined),
              _buildDivider(),
              _buildStatItem('Streak', '${user.streakDays} Days', Icons.local_fire_department_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryLight),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 32,
      width: 1,
      color: AppColors.border,
    );
  }
}

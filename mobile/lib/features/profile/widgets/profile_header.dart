import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/user_model.dart';

/// Top profile card with user avatar, name, tier badge, and quick stats.
class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onEdit;

  const ProfileHeader({
    super.key,
    required this.user,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                border: Border.all(color: AppColors.primaryLight, width: 3),
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, color: Colors.white, size: 50),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
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

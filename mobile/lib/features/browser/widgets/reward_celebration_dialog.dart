import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/buttons/app_button.dart';

class RewardCelebrationDialog extends StatelessWidget {
  final String taskTitle;
  final int coinsEarned;
  final int xpEarned;
  final bool requiresQuiz;
  final VoidCallback onContinue;

  const RewardCelebrationDialog({
    super.key,
    required this.taskTitle,
    required this.coinsEarned,
    required this.xpEarned,
    this.requiresQuiz = false,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: AppConstants.borderRadiusXl,
          border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.coinGold, Color(0xFFFFA000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coinGold.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.monetization_on_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              requiresQuiz ? 'Watch Completed!' : 'Task Completed!',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              taskTitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppConstants.borderRadiusLg,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        '+$coinsEarned',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.coinGold,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Coins',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: AppColors.border,
                  ),
                  Column(
                    children: [
                      Text(
                        '+$xpEarned',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'XP',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: requiresQuiz ? 'Take Verification Quiz' : 'Claim Reward',
              onPressed: onContinue,
              prefixIcon: Icon(
                requiresQuiz
                    ? CupertinoIcons.question_circle_fill
                    : CupertinoIcons.checkmark_seal_fill,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

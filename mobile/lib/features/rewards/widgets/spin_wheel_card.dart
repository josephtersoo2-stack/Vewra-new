import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../services/dummy_data_service.dart';
import '../../../../models/gamification_model.dart';

/// Interactive visual Spin Wheel Card for daily retention and reward surprises.
class SpinWheelCard extends StatefulWidget {
  final VoidCallback? onRewardClaimed;

  const SpinWheelCard({
    super.key,
    this.onRewardClaimed,
  });

  @override
  State<SpinWheelCard> createState() => _SpinWheelCardState();
}

class _SpinWheelCardState extends State<SpinWheelCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _wheelAnimation;
  bool _isSpinning = false;
  int _availableSpins = 1;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _wheelAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerSpin() {
    if (_isSpinning || _availableSpins <= 0) return;

    setState(() {
      _isSpinning = true;
    });

    _animController.reset();
    _animController.forward().then((_) {
      if (!mounted) return;
      // Simulated winner (Jackpot or high tier reward)
      final winner = DummyDataService.spinRewards[3]; // 250 Coins
      setState(() {
        _isSpinning = false;
        _availableSpins = 0;
      });

      _showWinnerDialog(winner);
      widget.onRewardClaimed?.call();
    });
  }

  void _showWinnerDialog(SpinRewardModel reward) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: AppConstants.borderRadiusLg,
          side: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.stars_rounded, color: AppColors.amber, size: 28),
            SizedBox(width: 8),
            Text('Congratulations!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.space16),
              decoration: BoxDecoration(
                color: reward.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(reward.icon, size: 48, color: reward.color),
            ),
            const SizedBox(height: AppConstants.space16),
            Text(
              'You Won ${reward.label}!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '+${reward.coins} Coins & +${reward.xp} XP credited to your wallet.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Claim Reward'),
          ),
        ],
      ),
    );
  }

  void _showOddsModal() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXl)),
      ),
      builder: (ctx) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Possible Wheel Rewards',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.space12),
            const Text(
              'Every user gets 1 free spin every 24 hours. Additional spins can be unlocked from milestone streaks.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppConstants.space16),
            ...DummyDataService.spinRewards.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.space10),
                child: Row(
                  children: [
                    Icon(r.icon, size: 20, color: r.color),
                    const SizedBox(width: AppConstants.space12),
                    Expanded(
                      child: Text(
                        r.label,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppConstants.borderRadiusSm,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        r.probabilityText,
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.space16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.gradient,
      padding: const EdgeInsets.all(AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Spin Title & Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.space8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.casino_rounded, size: 20, color: AppColors.primaryLight),
              ),
              const SizedBox(width: AppConstants.space10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Fortune Wheel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Spin to win up to 1,000 Coins & Boosters',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textTertiary),
                onPressed: _showOddsModal,
                tooltip: 'View Reward Odds',
              ),
            ],
          ),

          const SizedBox(height: AppConstants.space20),

          // Central Animated Wheel Graphic
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated Rotating Wheel
                AnimatedBuilder(
                  animation: _wheelAnimation,
                  builder: (context, child) {
                    final rotation = _wheelAnimation.value * (2 * math.pi * 5); // 5 full rotations
                    return Transform.rotate(
                      angle: rotation,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryLight, width: 4),
                      gradient: const SweepGradient(
                        colors: [
                          Color(0xFF6366F1),
                          Color(0xFF06B6D4),
                          Color(0xFF10B981),
                          Color(0xFFF59E0B),
                          Color(0xFFEC4899),
                          Color(0xFFFFB800),
                          Color(0xFF6366F1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars_rounded, color: AppColors.amber, size: 28),
                      ),
                    ),
                  ),
                ),

                // Top Pointer Indicator
                Positioned(
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryDark, size: 24),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.space20),

          // Status & Spin Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _availableSpins > 0 ? '$_availableSpins Free Spin Ready' : 'Next Spin in 18h 42m',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _availableSpins > 0 ? AppColors.emerald : AppColors.textTertiary,
                    ),
                  ),
                  const Text(
                    'Refreshes daily at 00:00 UTC',
                    style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _availableSpins > 0 && !_isSpinning ? _triggerSpin : null,
                icon: _isSpinning
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(_isSpinning ? 'Spinning...' : 'Spin Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
                  shape: RoundedRectangleBorder(borderRadius: AppConstants.borderRadiusMd),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

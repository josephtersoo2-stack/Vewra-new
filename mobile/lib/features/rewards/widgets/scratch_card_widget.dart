import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../models/gamification_model.dart';

/// Interactive Scratch Card Widget with scratch-off reveal action and reward claiming.
class ScratchCardWidget extends StatefulWidget {
  final ScratchCardModel card;
  final VoidCallback? onClaim;

  const ScratchCardWidget({
    super.key,
    required this.card,
    this.onClaim,
  });

  @override
  State<ScratchCardWidget> createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> {
  late bool _isScratched;

  @override
  void initState() {
    super.initState();
    _isScratched = widget.card.isScratched;
  }

  void _revealCard() {
    if (_isScratched) return;
    setState(() {
      _isScratched = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.emerald,
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Revealed: +${widget.card.rewardCoins} Coins & +${widget.card.rewardXp} XP!',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
    widget.onClaim?.call();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return AppCard(
      variant: AppCardVariant.standard,
      padding: const EdgeInsets.all(AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Rarity & Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 18, color: card.cardColor),
                  const SizedBox(width: 6),
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: card.cardColor.withValues(alpha: 0.15),
                  borderRadius: AppConstants.borderRadiusSm,
                  border: Border.all(color: card.cardColor, width: 1),
                ),
                child: Text(
                  card.rarity.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: card.cardColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            card.subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),

          const SizedBox(height: AppConstants.space14),

          // Scratchable Interactive Area
          InkWell(
            onTap: _revealCard,
            borderRadius: AppConstants.borderRadiusMd,
            child: AnimatedContainer(
              duration: AppConstants.animMedium,
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: AppConstants.borderRadiusMd,
                gradient: _isScratched
                    ? LinearGradient(
                        colors: [
                          AppColors.emerald.withValues(alpha: 0.2),
                          AppColors.surfaceElevated,
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          card.cardColor.withValues(alpha: 0.3),
                          AppColors.surfaceLight,
                        ],
                      ),
                border: Border.all(
                  color: _isScratched ? AppColors.emerald : AppColors.border,
                  width: _isScratched ? 1.5 : 1.0,
                ),
              ),
              child: Center(
                child: _isScratched
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 30),
                          const SizedBox(height: 4),
                          Text(
                            '+${card.rewardCoins} Coins & +${card.rewardXp} XP',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'Reward Unlocked!',
                            style: TextStyle(fontSize: 11, color: AppColors.emerald, fontWeight: FontWeight.w700),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app_rounded, color: card.cardColor, size: 28),
                          const SizedBox(height: 4),
                          const Text(
                            'TAP TO SCRATCH & REVEAL',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'Hidden coin prizes inside',
                            style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../models/mission_model.dart';

/// Missions & Daily Objectives Widget with progress bars and milestone rewards.
class MissionsSection extends StatefulWidget {
  final List<MissionModel> missions;
  final Function(MissionModel)? onClaim;

  const MissionsSection({
    super.key,
    required this.missions,
    this.onClaim,
  });

  @override
  State<MissionsSection> createState() => _MissionsSectionState();
}

class _MissionsSectionState extends State<MissionsSection> {
  late Map<String, bool> _claimedMap;

  @override
  void initState() {
    super.initState();
    _claimedMap = {for (var m in widget.missions) m.id: m.isClaimed};
  }

  void _handleClaim(MissionModel mission) {
    setState(() {
      _claimedMap[mission.id] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.emerald,
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Mission Complete: +${mission.rewardCoins} Coins & +${mission.rewardXp} XP!',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
    widget.onClaim?.call(mission);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Countdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment_turned_in_rounded, size: 20, color: AppColors.primaryLight),
                SizedBox(width: AppConstants.space6),
                Text(
                  'Daily Missions & Quests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppConstants.borderRadiusSm,
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 12, color: AppColors.textTertiary),
                  SizedBox(width: 4),
                  Text(
                    'Resets in 7h 14m',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.space12),

        ...widget.missions.map((mission) {
          final isClaimed = _claimedMap[mission.id] ?? false;
          final isReadyToClaim = mission.isCompleted && !isClaimed;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.space10),
            child: AppCard(
              variant: isReadyToClaim
                  ? AppCardVariant.elevated
                  : (mission.isCompleted ? AppCardVariant.standard : AppCardVariant.outlined),
              padding: const EdgeInsets.all(AppConstants.space14),
              child: Row(
                children: [
                  // Leading Category / Progress Icon
                  Container(
                    padding: const EdgeInsets.all(AppConstants.space8),
                    decoration: BoxDecoration(
                      color: (mission.isCompleted ? AppColors.emerald : AppColors.primary)
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isClaimed
                          ? Icons.check_circle_rounded
                          : (isReadyToClaim ? Icons.stars_rounded : Icons.radio_button_unchecked_rounded),
                      size: 20,
                      color: mission.isCompleted ? AppColors.emerald : AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: AppConstants.space12),

                  // Mission Details & Progress Bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              mission.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${mission.currentCount}/${mission.targetCount}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: mission.isCompleted ? AppColors.emerald : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          mission.description,
                          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: AppConstants.space6),
                        ClipRRect(
                          borderRadius: AppConstants.borderRadiusFull,
                          child: LinearProgressIndicator(
                            value: mission.progress,
                            minHeight: 4,
                            backgroundColor: AppColors.surface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              mission.isCompleted ? AppColors.emerald : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppConstants.space12),

                  // Reward Tag / Claim Button
                  if (isReadyToClaim)
                    ElevatedButton(
                      onPressed: () => _handleClaim(mission),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: AppConstants.borderRadiusSm),
                        elevation: 0,
                      ),
                      child: const Text('Claim', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${mission.rewardCoins}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isClaimed ? AppColors.textTertiary : AppColors.amber,
                          ),
                        ),
                        Text(
                          '+${mission.rewardXp} XP',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

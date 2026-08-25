import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/layout/app_header.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/cards/level_progress_card.dart';
import '../../../core/widgets/cards/reward_card.dart';
import '../../../core/widgets/cards/leaderboard_card.dart';
import '../../../services/dummy_data_service.dart';

/// Screen showcasing user Level/XP, Daily Check-in Streak, Achievements, Leaderboard, and Tournament competitions.
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  late List<bool> _dailyClaimedStatus;

  @override
  void initState() {
    super.initState();
    _dailyClaimedStatus = DummyDataService.dailyRewards.map((r) => r.isClaimed).toList();
  }

  void _claimTodayReward(int index) {
    setState(() {
      _dailyClaimedStatus[index] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.emerald,
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.white),
            const SizedBox(width: AppConstants.space8),
            Text(
              'Claimed +${DummyDataService.dailyRewards[index].rewardCoins} Coins!',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = DummyDataService.currentUser;
    final tournament = DummyDataService.activeTournament;

    return Scaffold(
      appBar: const AppHeader(
        title: 'Rewards & XP Hub',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPaddingH,
          vertical: AppConstants.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Level & XP Progress Card
            LevelProgressCard(
              level: user.level,
              currentXp: user.xp,
              nextLevelXp: user.xpNextLevel,
              trustScore: user.trustScore,
              verificationStatus: user.verificationStatus,
            ),

            const SizedBox(height: AppConstants.space24),

            // 2. Daily Check-in Streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, size: 20, color: AppColors.amber),
                    SizedBox(width: AppConstants.space6),
                    Text(
                      '7-Day Streak Rewards',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${user.streakDays} Day Streak',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.space12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  DummyDataService.dailyRewards.length,
                  (index) {
                    final item = DummyDataService.dailyRewards[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: AppConstants.space8),
                      child: RewardCard(
                        day: item.day,
                        rewardCoins: item.rewardCoins,
                        isClaimed: _dailyClaimedStatus[index],
                        isToday: item.isToday,
                        onClaim: () => _claimTodayReward(index),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: AppConstants.space24),

            // 3. Weekly Tournament Competition Card
            AppCard(
              variant: AppCardVariant.gradient,
              padding: const EdgeInsets.all(AppConstants.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppConstants.space8),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emoji_events_rounded, size: 20, color: AppColors.amber),
                      ),
                      const SizedBox(width: AppConstants.space10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tournament.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Prize Pool: ${tournament.prizePool}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppConstants.borderRadiusSm,
                        ),
                        child: Text(
                          tournament.timeLeft,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.space10),
                  Text(
                    tournament.description,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppConstants.space12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Current Rank: #${tournament.userRank}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      Text(
                        '${tournament.participantsCount} Players',
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.space24),

            // 4. Global Leaderboard Preview
            const Row(
              children: [
                Icon(Icons.leaderboard_rounded, size: 20, color: AppColors.cyan),
                SizedBox(width: AppConstants.space6),
                Text(
                  'Top Earners Leaderboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.space12),

            ...DummyDataService.leaderboardEntries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.space8),
                child: LeaderboardCard(
                  rank: entry.rank,
                  username: entry.username,
                  coinsEarned: entry.coinsEarned,
                  tierBadge: entry.tierBadge,
                  isCurrentUser: entry.isCurrentUser,
                ),
              ),
            ),

            const SizedBox(height: AppConstants.space24),

            // 5. Achievements Preview
            const Row(
              children: [
                Icon(Icons.military_tech_rounded, size: 20, color: AppColors.primaryLight),
                SizedBox(width: AppConstants.space6),
                Text(
                  'Achievements & Badges',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.space12),

            ...DummyDataService.achievements.map(
              (ach) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.space8),
                child: AppCard(
                  variant: ach.isCompleted ? AppCardVariant.standard : AppCardVariant.outlined,
                  padding: const EdgeInsets.all(AppConstants.space14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppConstants.space8),
                        decoration: BoxDecoration(
                          color: (ach.isCompleted ? AppColors.emerald : AppColors.surface)
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          ach.isCompleted ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                          size: 20,
                          color: ach.isCompleted ? AppColors.emerald : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ach.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              ach.description,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppConstants.space6),
                            ClipRRect(
                              borderRadius: AppConstants.borderRadiusFull,
                              child: LinearProgressIndicator(
                                value: ach.progress,
                                minHeight: 4,
                                backgroundColor: AppColors.surface,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ach.isCompleted ? AppColors.emerald : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppConstants.space10),
                      Text(
                        '+${ach.rewardCoins}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/layout/app_header.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/cards/level_progress_card.dart';
import '../../../core/widgets/cards/reward_card.dart';
import '../../../core/widgets/cards/leaderboard_card.dart';
import '../widgets/spin_wheel_card.dart';
import '../widgets/scratch_card_widget.dart';
import '../widgets/missions_section.dart';
import '../widgets/challenges_section.dart';
import '../widgets/feature_unlock_card.dart';
import '../../../services/dummy_data_service.dart';

/// Complete Rewards & Gamification Hub containing Daily Rewards, Spin Wheel, Scratch Cards,
/// Missions, Challenges, Leaderboards, Tournament Events, and Feature Unlock Progression.
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  int _selectedTabIndex = 0; // 0: Daily & Spins, 1: Events & Ranks, 2: Challenges & Unlocks
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
        showMenuButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPaddingH,
          vertical: AppConstants.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Level & XP Progress Overview Card
            LevelProgressCard(
              level: user.level,
              currentXp: user.xp,
              nextLevelXp: user.xpNextLevel,
              trustScore: user.trustScore,
              verificationStatus: user.verificationStatus,
            ),

            const SizedBox(height: AppConstants.space16),

            // 2. Sub-Category Tabs (Daily & Spins, Events & Ranks, Challenges & Unlocks)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabPill(0, 'Daily & Spins', Icons.casino_rounded),
                  const SizedBox(width: AppConstants.space8),
                  _buildTabPill(1, 'Events & Ranks', Icons.emoji_events_rounded),
                  const SizedBox(width: AppConstants.space8),
                  _buildTabPill(2, 'Challenges & Unlocks', Icons.military_tech_rounded),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.space16),

            // 3. Tab Content
            if (_selectedTabIndex == 0) ...[
              // TAB 0: Daily & Spins
              // A. 7-Day Streak Calendar
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

              const SizedBox(height: AppConstants.space20),

              // B. Daily Fortune Wheel Card
              const SpinWheelCard(),

              const SizedBox(height: AppConstants.space20),

              // C. Scratch Cards
              const Row(
                children: [
                  Icon(Icons.style_rounded, size: 20, color: AppColors.amber),
                  SizedBox(width: AppConstants.space6),
                  Text(
                    'Mystery Scratch Cards',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.space12),

              ...DummyDataService.scratchCards.map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.space10),
                  child: ScratchCardWidget(card: card),
                ),
              ),

              const SizedBox(height: AppConstants.space20),

              // D. Daily Missions & Quests
              MissionsSection(missions: DummyDataService.dailyMissions),
            ] else if (_selectedTabIndex == 1) ...[
              // TAB 1: Events & Ranks
              // A. Weekly Tournament Card
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

              const SizedBox(height: AppConstants.space20),

              // B. Leaderboard List
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

              const SizedBox(height: AppConstants.space20),

              // C. Achievements List
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
                            color: (ach.isCompleted ? AppColors.emerald : AppColors.primary)
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
            ] else ...[
              // TAB 2: Challenges & Progression
              // A. Personal & Community Challenges
              ChallengesSection(challenges: DummyDataService.challenges),

              const SizedBox(height: AppConstants.space24),

              // B. Feature Unlock Progression
              const Row(
                children: [
                  Icon(Icons.lock_open_rounded, size: 20, color: AppColors.emerald),
                  SizedBox(width: AppConstants.space6),
                  Text(
                    'Feature Unlock Progression',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Unlock advanced ecosystem modules by boosting your Level, Verification, and Trust Score.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppConstants.space12),

              ...DummyDataService.featureUnlocks.map(
                (unlock) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.space10),
                  child: FeatureUnlockCard(unlock: unlock),
                ),
              ),
            ],

            const SizedBox(height: AppConstants.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(int index, String title, IconData icon) {
    final bool isSelected = _selectedTabIndex == index;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppColors.textTertiary,
      ),
      label: Text(title),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedTabIndex = index);
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      side: BorderSide(
        color: isSelected ? AppColors.primaryLight : AppColors.border,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppConstants.borderRadiusFull,
      ),
      showCheckmark: false,
    );
  }
}

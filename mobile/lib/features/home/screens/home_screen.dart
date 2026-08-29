import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../../services/dummy_data_service.dart';
import '../../../models/task_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../tasks/providers/task_feed_provider.dart';
import '../widgets/greeting_header.dart';
import '../widgets/home_ad_spot_card.dart';
import '../widgets/daily_goal_card.dart';
import '../../../core/widgets/cards/level_progress_card.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../tasks/widgets/task_card.dart';

/// Home Dashboard screen for VEWRA with level progress, ecosystem shortcuts, and task feeds.
class HomeScreen extends ConsumerWidget {
  final VoidCallback? onSwitchToTasks;
  final VoidCallback? onSwitchToWallet;
  final VoidCallback? onSwitchToRewards;

  const HomeScreen({
    super.key,
    this.onSwitchToTasks,
    this.onSwitchToWallet,
    this.onSwitchToRewards,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);
    final taskFeedState = ref.watch(taskFeedProvider);

    final user = profileState.user ?? authState.user ?? DummyDataService.currentUser;
    final tasks = taskFeedState.tasks;
    final tournament = DummyDataService.activeTournament;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.space12),

          // 1. Top Greeting Header
          GreetingHeader(
            user: user,
            onNotificationsTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),

          const SizedBox(height: AppConstants.space16),

          // 2. Featured Demo Ad Spot (Replaces Balance Card)
          const HomeAdSpotCard(),

          const SizedBox(height: AppConstants.space16),

          // 3. User Progress, Level & Trust Score Card
          LevelProgressCard(
            level: user.level,
            currentXp: user.xp,
            nextLevelXp: user.xpNextLevel,
            trustScore: user.trustScore,
            verificationStatus: user.verificationStatus,
            onTap: onSwitchToRewards,
          ),

          const SizedBox(height: AppConstants.space16),

          // 4. Quick Ecosystem Shortcuts (Marketplace, Community, Verification)
          Row(
            children: [
              Expanded(
                child: _buildEcosystemButton(
                  context,
                  title: 'Marketplace',
                  subtitle: 'Spend & Trade',
                  icon: Icons.storefront_rounded,
                  iconColor: AppColors.cyan,
                  route: AppRoutes.marketplace,
                ),
              ),
              const SizedBox(width: AppConstants.space10),
              Expanded(
                child: _buildEcosystemButton(
                  context,
                  title: 'Community',
                  subtitle: 'Posts & Tips',
                  icon: Icons.groups_rounded,
                  iconColor: AppColors.primaryLight,
                  route: AppRoutes.community,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.space16),

          // 5. Weekly Competition Ranking Card
          AppCard(
            variant: AppCardVariant.gradient,
            padding: const EdgeInsets.all(AppConstants.space14),
            onTap: onSwitchToRewards,
            child: Row(
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
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Prize Pool: ${tournament.prizePool} • Rank #${tournament.userRank}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.space16),

          // 6. Daily Watch Goal
          DailyGoalCard(
            completedTasks: user.tasksCompleted % 5 + 1,
            targetTasks: 5,
            minutesWatched: 16,
            targetMinutes: 30,
          ),

          const SizedBox(height: AppConstants.space24),

          // 7. Featured Tasks Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.featuredTasks,
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: onSwitchToTasks,
                child: Text(
                  AppStrings.seeAll,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.space8),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  isHorizontalCompact: true,
                  onTap: () => _openTaskDetails(context, task),
                );
              },
            ),
          ),

          const SizedBox(height: AppConstants.space24),

          // 8. Recommended Tasks Vertical List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.recommendedTasks,
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.space12),
          if (tasks.isEmpty && !taskFeedState.isLoading)
            AppCard(
              variant: AppCardVariant.outlined,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.play_circle_outline_rounded, size: 36, color: AppColors.textMuted.withValues(alpha: 0.7)),
                    const SizedBox(height: 10),
                    Text(
                      'No tasks available right now',
                      style: AppTypography.titleSmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tasks created in the admin portal will appear here automatically.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            )
          else if (taskFeedState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.take(3).length,
              separatorBuilder: (context, index) => const SizedBox(height: AppConstants.space16),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () => _openTaskDetails(context, task),
                  onStartTap: () => _openTaskDetails(context, task),
                );
              },
            ),
          const SizedBox(height: AppConstants.space32),
        ],
      ),
    );
  }

  Widget _buildEcosystemButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String route,
  }) {
    return AppCard(
      variant: AppCardVariant.standard,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space12,
        vertical: AppConstants.space10,
      ),
      onTap: () => Navigator.pushNamed(context, route),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.space8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: AppConstants.borderRadiusSm,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: AppConstants.space10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openTaskDetails(BuildContext context, TaskModel task) {
    Navigator.pushNamed(
      context,
      AppRoutes.taskDetails,
      arguments: task,
    );
  }
}

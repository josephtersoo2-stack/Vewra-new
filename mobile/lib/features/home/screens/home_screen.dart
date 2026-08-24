import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../../services/dummy_data_service.dart';
import '../../../models/task_model.dart';
import '../widgets/greeting_header.dart';
import '../widgets/wallet_summary_card.dart';
import '../widgets/daily_goal_card.dart';
import '../../tasks/widgets/task_card.dart';

/// Home Dashboard screen for VEWRA.
class HomeScreen extends StatelessWidget {
  final VoidCallback? onSwitchToTasks;
  final VoidCallback? onSwitchToWallet;

  const HomeScreen({
    super.key,
    this.onSwitchToTasks,
    this.onSwitchToWallet,
  });

  @override
  Widget build(BuildContext context) {
    final user = DummyDataService.currentUser;
    final wallet = DummyDataService.currentWallet;
    final tasks = DummyDataService.tasks;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.space12),
          // Top Greeting Header
          GreetingHeader(
            user: user,
            onNotificationsTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          const SizedBox(height: AppConstants.space20),
          // Hero Wallet Summary Card
          WalletSummaryCard(
            wallet: wallet,
            onWalletTap: onSwitchToWallet,
            onWithdrawTap: onSwitchToWallet,
          ),
          const SizedBox(height: AppConstants.space16),
          // Daily Watch Goal
          DailyGoalCard(
            completedTasks: user.tasksCompleted % 5 + 1,
            targetTasks: 5,
            minutesWatched: 16,
            targetMinutes: 30,
          ),
          const SizedBox(height: AppConstants.space24),
          // Featured Tasks Section
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
          // Recommended Tasks Vertical List
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

  void _openTaskDetails(BuildContext context, TaskModel task) {
    Navigator.pushNamed(
      context,
      AppRoutes.taskDetails,
      arguments: task,
    );
  }
}

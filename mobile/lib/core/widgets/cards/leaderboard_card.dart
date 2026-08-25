import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';
import 'app_card.dart';

/// Reusable Leaderboard Ranking Card for user competitions and rankings.
class LeaderboardCard extends StatelessWidget {
  final int rank;
  final String username;
  final String? avatarUrl;
  final int coinsEarned;
  final String tierBadge;
  final bool isCurrentUser;

  const LeaderboardCard({
    super.key,
    required this.rank,
    required this.username,
    this.avatarUrl,
    required this.coinsEarned,
    required this.tierBadge,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    Color rankColor = AppColors.textSecondary;
    if (rank == 1) rankColor = AppColors.amber;
    if (rank == 2) rankColor = const Color(0xFFC0C0C0); // Silver
    if (rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze

    return AppCard(
      variant: isCurrentUser ? AppCardVariant.elevated : AppCardVariant.standard,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space16,
        vertical: AppConstants.space12,
      ),
      child: Row(
        children: [
          // Rank Indicator
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank <= 3 ? rankColor.withValues(alpha: 0.15) : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: rank <= 3 ? rankColor : AppColors.border,
                width: 1.2,
              ),
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: rankColor,
              ),
            ),
          ),

          const SizedBox(width: AppConstants.space12),

          // User Avatar Placeholder
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryLight,
              ),
            ),
          ),

          const SizedBox(width: AppConstants.space12),

          // Username & Tier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        username,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                          color: isCurrentUser ? AppColors.primaryLight : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: AppConstants.space6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: AppConstants.borderRadiusSm,
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  tierBadge,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Coins Earned
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on_rounded, size: 16, color: AppColors.amber),
              const SizedBox(width: AppConstants.space4),
              Text(
                '$coinsEarned',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

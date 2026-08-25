import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../models/challenge_model.dart';

/// Challenges Widget for Personal and Global Community competitive goals.
class ChallengesSection extends StatefulWidget {
  final List<ChallengeModel> challenges;
  final Function(ChallengeModel)? onJoin;

  const ChallengesSection({
    super.key,
    required this.challenges,
    this.onJoin,
  });

  @override
  State<ChallengesSection> createState() => _ChallengesSectionState();
}

class _ChallengesSectionState extends State<ChallengesSection> {
  int _selectedFilter = 0; // 0: All, 1: Personal, 2: Community
  late Map<String, bool> _joinedMap;

  @override
  void initState() {
    super.initState();
    _joinedMap = {for (var c in widget.challenges) c.id: c.isJoined};
  }

  List<ChallengeModel> get _filteredChallenges {
    if (_selectedFilter == 1) {
      return widget.challenges.where((c) => !c.isCommunityChallenge).toList();
    } else if (_selectedFilter == 2) {
      return widget.challenges.where((c) => c.isCommunityChallenge).toList();
    }
    return widget.challenges;
  }

  void _handleJoin(ChallengeModel challenge) {
    setState(() {
      _joinedMap[challenge.id] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text('Joined "${challenge.title}"! Progress is now tracked.'),
      ),
    );
    widget.onJoin?.call(challenge);
  }

  @override
  Widget build(BuildContext context) {
    final challenges = _filteredChallenges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Category Chips
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.flag_rounded, size: 20, color: AppColors.cyan),
                SizedBox(width: AppConstants.space6),
                Text(
                  'Active Challenges',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildFilterChip(0, 'All'),
                const SizedBox(width: 4),
                _buildFilterChip(1, 'Personal'),
                const SizedBox(width: 4),
                _buildFilterChip(2, 'Community'),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppConstants.space12),

        ...challenges.map((ch) {
          final isJoined = _joinedMap[ch.id] ?? false;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.space12),
            child: AppCard(
              variant: ch.isCommunityChallenge ? AppCardVariant.gradient : AppCardVariant.standard,
              padding: const EdgeInsets.all(AppConstants.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Community badge & Time Left
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (ch.isCommunityChallenge ? AppColors.cyan : AppColors.primary)
                              .withValues(alpha: 0.15),
                          borderRadius: AppConstants.borderRadiusSm,
                          border: Border.all(
                            color: ch.isCommunityChallenge ? AppColors.cyan : AppColors.primary,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          ch.isCommunityChallenge ? 'COMMUNITY' : 'PERSONAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: ch.isCommunityChallenge ? AppColors.cyan : AppColors.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${ch.participantsCount} participants',
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 12, color: AppColors.amber),
                          const SizedBox(width: 4),
                          Text(
                            ch.timeLeft,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.amber),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.space10),

                  // Challenge Title
                  Text(
                    ch.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ch.description,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                  ),

                  const SizedBox(height: AppConstants.space12),

                  // Progress Metric & Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${ch.goalMetric}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      Text(
                        '${(ch.progress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.cyan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: AppConstants.borderRadiusFull,
                    child: LinearProgressIndicator(
                      value: ch.progress,
                      minHeight: 5,
                      backgroundColor: AppColors.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ch.isCommunityChallenge ? AppColors.cyan : AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.space14),

                  // Footer: Rewards & Join CTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monetization_on_rounded, size: 16, color: AppColors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '+${ch.rewardCoins} Coins',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.amber,
                            ),
                          ),
                          if (ch.rewardBadge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.amber.withValues(alpha: 0.15),
                                borderRadius: AppConstants.borderRadiusSm,
                              ),
                              child: Text(
                                ch.rewardBadge!,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.amber),
                              ),
                            ),
                          ],
                        ],
                      ),
                      ElevatedButton(
                        onPressed: isJoined ? null : () => _handleJoin(ch),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isJoined ? AppColors.surface : AppColors.primary,
                          foregroundColor: isJoined ? AppColors.textTertiary : Colors.white,
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.space14),
                          shape: RoundedRectangleBorder(borderRadius: AppConstants.borderRadiusMd),
                          elevation: 0,
                        ),
                        child: Text(
                          isJoined ? 'In Progress' : 'Join Challenge',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
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

  Widget _buildFilterChip(int index, String label) {
    final bool isSelected = _selectedFilter == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: AppConstants.borderRadiusFull,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: AppConstants.borderRadiusFull,
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryLight : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

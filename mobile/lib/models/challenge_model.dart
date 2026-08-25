/// Model representing personal and community challenges.
class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;
  final int rewardXp;
  final String? rewardBadge;
  final int participantsCount;
  final String timeLeft;
  final double progress; // 0.0 to 1.0
  final bool isCommunityChallenge;
  final bool isJoined;
  final String goalMetric;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.rewardXp,
    this.rewardBadge,
    required this.participantsCount,
    required this.timeLeft,
    required this.progress,
    this.isCommunityChallenge = false,
    this.isJoined = false,
    required this.goalMetric,
  });
}

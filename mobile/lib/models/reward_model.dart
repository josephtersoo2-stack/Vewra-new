/// Daily check-in reward model
class DailyRewardModel {
  final int day;
  final int rewardCoins;
  final bool isClaimed;
  final bool isToday;

  const DailyRewardModel({
    required this.day,
    required this.rewardCoins,
    this.isClaimed = false,
    this.isToday = false,
  });
}

/// Leaderboard ranking entry model
class LeaderboardEntryModel {
  final int rank;
  final String username;
  final String? avatarUrl;
  final int coinsEarned;
  final String tierBadge;
  final bool isCurrentUser;

  const LeaderboardEntryModel({
    required this.rank,
    required this.username,
    this.avatarUrl,
    required this.coinsEarned,
    required this.tierBadge,
    this.isCurrentUser = false,
  });
}

/// User achievement milestone model
class AchievementModel {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final String iconName;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.progress,
    this.isCompleted = false,
    required this.iconName,
  });
}

/// Tournament / Competition model
class CompetitionModel {
  final String id;
  final String title;
  final String description;
  final String prizePool;
  final String timeLeft;
  final int participantsCount;
  final int userRank;

  const CompetitionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.prizePool,
    required this.timeLeft,
    required this.participantsCount,
    required this.userRank,
  });
}

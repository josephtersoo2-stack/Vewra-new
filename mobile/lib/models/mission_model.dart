/// Model representing daily and milestone missions for player retention.
class MissionModel {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;
  final int rewardXp;
  final int currentCount;
  final int targetCount;
  final bool isCompleted;
  final bool isClaimed;
  final String category; // 'Daily', 'Weekly', 'Milestone'

  const MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.rewardXp,
    required this.currentCount,
    required this.targetCount,
    this.isCompleted = false,
    this.isClaimed = false,
    this.category = 'Daily',
  });

  double get progress => (currentCount / targetCount).clamp(0.0, 1.0);
}

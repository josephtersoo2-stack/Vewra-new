/// Real-time progress model returned by heartbeat pings.
class WatchProgressModel {
  final String id;
  final String state;
  final int creditedWatchSeconds;
  final int requiredSeconds;
  final double progressPercentage;
  final bool quizRequired;
  final bool isSatisfied;
  final String rewardType;
  final int sessionCoinsEarned;

  const WatchProgressModel({
    required this.id,
    required this.state,
    required this.creditedWatchSeconds,
    required this.requiredSeconds,
    required this.progressPercentage,
    this.quizRequired = false,
    this.isSatisfied = false,
    this.rewardType = 'target',
    this.sessionCoinsEarned = 0,
  });

  factory WatchProgressModel.fromJson(Map<String, dynamic> json) {
    return WatchProgressModel(
      id: json['id']?.toString() ?? '',
      state: json['state']?.toString() ?? 'ACTIVE',
      creditedWatchSeconds:
          (json['credited_watch_seconds'] as num?)?.toInt() ?? 0,
      requiredSeconds: (json['required_seconds'] as num?)?.toInt() ?? 60,
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      quizRequired: json['quiz_required'] as bool? ?? false,
      isSatisfied: json['is_satisfied'] as bool? ?? false,
      rewardType: json['reward_type']?.toString() ?? 'target',
      sessionCoinsEarned: (json['session_coins_earned'] as num?)?.toInt() ?? 0,
    );
  }
}

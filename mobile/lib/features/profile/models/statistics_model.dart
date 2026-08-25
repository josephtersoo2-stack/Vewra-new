/// Model representing aggregated user engagement metrics.
class UserStatisticsModel {
  final int tasksCompleted;
  final int videosWatched;
  final int quizzesCompleted;
  final int commentsCreated;
  final int referrals;
  final double totalRewards;

  const UserStatisticsModel({
    this.tasksCompleted = 0,
    this.videosWatched = 0,
    this.quizzesCompleted = 0,
    this.commentsCreated = 0,
    this.referrals = 0,
    this.totalRewards = 0.0,
  });

  factory UserStatisticsModel.fromJson(Map<String, dynamic> json) {
    return UserStatisticsModel(
      tasksCompleted: (json['tasks_completed'] as num?)?.toInt() ?? 0,
      videosWatched: (json['videos_watched'] as num?)?.toInt() ?? 0,
      quizzesCompleted: (json['quizzes_completed'] as num?)?.toInt() ?? 0,
      commentsCreated: (json['comments_created'] as num?)?.toInt() ?? 0,
      referrals: (json['referrals'] as num?)?.toInt() ?? 0,
      totalRewards: double.tryParse(json['total_rewards']?.toString() ?? '') ??
          (json['total_rewards'] as num?)?.toDouble() ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tasks_completed': tasksCompleted,
      'videos_watched': videosWatched,
      'quizzes_completed': quizzesCompleted,
      'comments_created': commentsCreated,
      'referrals': referrals,
      'total_rewards': totalRewards,
    };
  }
}

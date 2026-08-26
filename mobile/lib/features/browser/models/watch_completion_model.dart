/// Server response model for completion verification.
class WatchCompletionModel {
  final String status;
  final String message;
  final int rewardCoins;
  final String rewardCash;
  final int rewardXp;
  final String? rewardReference;
  final String? attemptId;
  final String? code;
  final double? progressPercentage;

  const WatchCompletionModel({
    required this.status,
    required this.message,
    this.rewardCoins = 0,
    this.rewardCash = '0.00',
    this.rewardXp = 0,
    this.rewardReference,
    this.attemptId,
    this.code,
    this.progressPercentage,
  });

  bool get isCompleted => status == 'COMPLETED' || status == 'ALREADY_COMPLETED';
  bool get isAwaitingQuiz => status == 'AWAITING_QUIZ';
  bool get isIncomplete => status == 'INCOMPLETE';

  factory WatchCompletionModel.fromJson(Map<String, dynamic> json) {
    final reward = json['reward'] as Map<String, dynamic>?;
    return WatchCompletionModel(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      rewardCoins: (reward?['coins'] as num?)?.toInt() ?? 0,
      rewardCash: reward?['cash']?.toString() ?? '0.00',
      rewardXp: (reward?['xp'] as num?)?.toInt() ?? 0,
      rewardReference: reward?['reference']?.toString(),
      attemptId: json['attempt_id']?.toString(),
      code: json['code']?.toString(),
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble(),
    );
  }
}

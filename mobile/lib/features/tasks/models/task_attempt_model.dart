/// Represents a user's task attempt returned by the backend.
class TaskAttemptModel {
  final String id;
  final String taskId;
  final String taskTitle;
  final String taskThumbnail;
  final int rewardCoins;
  final String status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool rewardGranted;
  final String? rewardReference;
  final bool quizRequired;
  final bool? quizPassed;
  final double? quizScore;
  final String failureReason;

  const TaskAttemptModel({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    this.taskThumbnail = '',
    required this.rewardCoins,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.rewardGranted = false,
    this.rewardReference,
    this.quizRequired = false,
    this.quizPassed,
    this.quizScore,
    this.failureReason = '',
  });

  bool get isCompleted => status == 'COMPLETED';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isAwaitingQuiz => status == 'AWAITING_QUIZ';

  factory TaskAttemptModel.fromJson(Map<String, dynamic> json) {
    return TaskAttemptModel(
      id: json['id']?.toString() ?? '',
      taskId: json['task_id']?.toString() ?? '',
      taskTitle: json['task_title']?.toString() ?? '',
      taskThumbnail: json['task_thumbnail']?.toString() ?? '',
      rewardCoins: (json['reward_coins'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'CREATED',
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'].toString())
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      rewardGranted: json['reward_granted'] as bool? ?? false,
      rewardReference: json['reward_reference']?.toString(),
      quizRequired: json['quiz_required'] as bool? ?? false,
      quizPassed: json['quiz_passed'] as bool?,
      quizScore: (json['quiz_score'] as num?)?.toDouble(),
      failureReason: json['failure_reason']?.toString() ?? '',
    );
  }
}

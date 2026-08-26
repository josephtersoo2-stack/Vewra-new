/// Authoritative server watch session model.
class WatchSessionModel {
  final String id;
  final String attemptId;
  final String taskId;
  final String status;
  final int requiredSeconds;
  final int creditedWatchSeconds;
  final double progressPercentage;
  final bool isSatisfied;
  final String sourceUrl;
  final String channelName;
  final int lastSequence;
  final String? watchToken;
  final bool quizRequired;

  const WatchSessionModel({
    required this.id,
    required this.attemptId,
    required this.taskId,
    required this.status,
    required this.requiredSeconds,
    this.creditedWatchSeconds = 0,
    this.progressPercentage = 0.0,
    this.isSatisfied = false,
    this.sourceUrl = '',
    this.channelName = '',
    this.lastSequence = 1,
    this.watchToken,
    this.quizRequired = false,
  });

  factory WatchSessionModel.fromJson(Map<String, dynamic> json) {
    return WatchSessionModel(
      id: json['id']?.toString() ?? '',
      attemptId: json['attempt_id']?.toString() ?? '',
      taskId: json['task_id']?.toString() ?? '',
      status: json['status']?.toString() ??
          json['state']?.toString() ??
          'ACTIVE',
      requiredSeconds: (json['required_seconds'] as num?)?.toInt() ?? 60,
      creditedWatchSeconds:
          (json['credited_watch_seconds'] as num?)?.toInt() ?? 0,
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      isSatisfied: json['is_satisfied'] as bool? ?? false,
      sourceUrl: json['source_url']?.toString() ?? '',
      channelName: json['channel_name']?.toString() ?? '',
      lastSequence: (json['last_sequence'] as num?)?.toInt() ?? 1,
      watchToken: json['watch_token']?.toString(),
      quizRequired: json['quiz_required'] as bool? ?? false,
    );
  }

  WatchSessionModel copyWith({
    String? id,
    String? attemptId,
    String? taskId,
    String? status,
    int? requiredSeconds,
    int? creditedWatchSeconds,
    double? progressPercentage,
    bool? isSatisfied,
    String? sourceUrl,
    String? channelName,
    int? lastSequence,
    String? watchToken,
    bool? quizRequired,
  }) {
    return WatchSessionModel(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      taskId: taskId ?? this.taskId,
      status: status ?? this.status,
      requiredSeconds: requiredSeconds ?? this.requiredSeconds,
      creditedWatchSeconds: creditedWatchSeconds ?? this.creditedWatchSeconds,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isSatisfied: isSatisfied ?? this.isSatisfied,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      channelName: channelName ?? this.channelName,
      lastSequence: lastSequence ?? this.lastSequence,
      watchToken: watchToken ?? this.watchToken,
      quizRequired: quizRequired ?? this.quizRequired,
    );
  }
}

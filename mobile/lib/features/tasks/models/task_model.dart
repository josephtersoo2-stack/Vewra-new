/// Authoritative Task model reflecting backend PostgreSQL task entity.
class TaskModel {
  final String id;
  final String title;
  final String slug;
  final String taskType;
  final String status;
  final String description;
  final List<String> instructions;
  final String thumbnailUrl;
  final String sourceUrl;
  final String sourcePlatform;
  final String channelName;
  final int rewardCoins;
  final double rewardCash;
  final int rewardXp;
  final int requiredWatchSeconds;
  final bool quizRequired;
  final int quizPassPercentage;
  final int minimumLevel;
  final int minimumTrustScore;
  final bool verificationRequired;
  final DateTime? createdAt;
  final bool isCompleted;
  final String? _customSearchKeywords;

  const TaskModel({
    required this.id,
    required this.title,
    this.slug = '',
    String? taskType,
    String? category,
    this.status = 'ACTIVE',
    this.description = '',
    this.instructions = const [],
    this.thumbnailUrl = '',
    String? sourceUrl,
    String? youtubeUrl,
    this.sourcePlatform = 'YouTube',
    this.channelName = '',
    required this.rewardCoins,
    double? rewardCash,
    double? rewardFiat,
    this.rewardXp = 25,
    int? requiredWatchSeconds,
    int? durationMinutes,
    String? searchKeywords,
    this.quizRequired = false,
    this.quizPassPercentage = 70,
    this.minimumLevel = 1,
    this.minimumTrustScore = 50,
    this.verificationRequired = false,
    this.createdAt,
    this.isCompleted = false,
  })  : taskType = taskType ?? category ?? 'VIDEO',
        sourceUrl = sourceUrl ?? youtubeUrl ?? '',
        rewardCash = rewardCash ?? rewardFiat ?? 0.0,
        requiredWatchSeconds = requiredWatchSeconds ??
            (durationMinutes != null ? durationMinutes * 60 : 60),
        _customSearchKeywords = searchKeywords;

  /// Approximate duration in minutes for legacy UI compatibility.
  int get durationMinutes => (requiredWatchSeconds / 60).ceil();

  /// Approximate fiat reward for legacy UI compatibility.
  double get rewardFiat => rewardCash > 0 ? rewardCash : (rewardCoins / 100.0);

  /// Helper category string
  String get category => taskType;

  /// Video URL for player
  String get youtubeUrl => sourceUrl;

  /// Search keywords assistance
  String get searchKeywords => _customSearchKeywords ?? title;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      taskType: json['task_type']?.toString() ??
          json['category']?.toString() ??
          'VIDEO',
      status: json['status']?.toString() ?? 'ACTIVE',
      description: json['description']?.toString() ?? '',
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
      sourceUrl: json['source_url']?.toString() ??
          json['youtube_url']?.toString() ??
          '',
      sourcePlatform: json['source_platform']?.toString() ?? 'YouTube',
      rewardCoins: (json['reward_coins'] as num?)?.toInt() ??
          int.tryParse(json['reward_coins']?.toString() ?? '0') ??
          0,
      rewardCash: json['reward_cash'] is num
          ? (json['reward_cash'] as num).toDouble()
          : double.tryParse(json['reward_cash']?.toString() ?? '0') ?? 0.0,
      rewardXp: (json['reward_xp'] as num?)?.toInt() ?? 25,
      requiredWatchSeconds: (json['required_watch_seconds'] as num?)?.toInt() ??
          ((json['duration_minutes'] as num?)?.toInt() != null
              ? (json['duration_minutes'] as num).toInt() * 60
              : 60),
      quizRequired: json['quiz_required'] as bool? ?? false,
      quizPassPercentage: (json['quiz_pass_percentage'] as num?)?.toInt() ?? 70,
      minimumLevel: (json['minimum_level'] as num?)?.toInt() ?? 1,
      minimumTrustScore: (json['minimum_trust_score'] as num?)?.toInt() ?? 50,
      verificationRequired: json['verification_required'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'task_type': taskType,
      'status': status,
      'description': description,
      'instructions': instructions,
      'thumbnail_url': thumbnailUrl,
      'source_url': sourceUrl,
      'source_platform': sourcePlatform,
      'channel_name': channelName,
      'reward_coins': rewardCoins,
      'reward_cash': rewardCash,
      'reward_xp': rewardXp,
      'required_watch_seconds': requiredWatchSeconds,
      'quiz_required': quizRequired,
      'quiz_pass_percentage': quizPassPercentage,
      'minimum_level': minimumLevel,
      'minimum_trust_score': minimumTrustScore,
      'verification_required': verificationRequired,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? taskType,
    String? status,
    String? description,
    List<String>? instructions,
    String? thumbnailUrl,
    String? sourceUrl,
    String? sourcePlatform,
    String? channelName,
    int? rewardCoins,
    double? rewardCash,
    int? rewardXp,
    int? requiredWatchSeconds,
    bool? quizRequired,
    int? quizPassPercentage,
    int? minimumLevel,
    int? minimumTrustScore,
    bool? verificationRequired,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourcePlatform: sourcePlatform ?? this.sourcePlatform,
      channelName: channelName ?? this.channelName,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      rewardCash: rewardCash ?? this.rewardCash,
      rewardXp: rewardXp ?? this.rewardXp,
      requiredWatchSeconds: requiredWatchSeconds ?? this.requiredWatchSeconds,
      quizRequired: quizRequired ?? this.quizRequired,
      quizPassPercentage: quizPassPercentage ?? this.quizPassPercentage,
      minimumLevel: minimumLevel ?? this.minimumLevel,
      minimumTrustScore: minimumTrustScore ?? this.minimumTrustScore,
      verificationRequired: verificationRequired ?? this.verificationRequired,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

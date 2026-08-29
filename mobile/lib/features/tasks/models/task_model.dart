/// Personalized randomized search instruction for YouTube discovery tasks.
class TaskInstructionModel {
  final String searchQuery;
  final String fullInstruction;
  final String title;
  final String thumbnailUrl;

  const TaskInstructionModel({
    required this.searchQuery,
    required this.fullInstruction,
    required this.title,
    required this.thumbnailUrl,
  });

  factory TaskInstructionModel.fromJson(Map<String, dynamic> json) {
    return TaskInstructionModel(
      searchQuery: json['search_query']?.toString() ?? '',
      fullInstruction: json['full_instruction']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'search_query': searchQuery,
        'full_instruction': fullInstruction,
        'title': title,
        'thumbnail_url': thumbnailUrl,
      };
}

/// Authoritative Task model reflecting backend PostgreSQL task entity and Vewra YouTube task schema.
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
  final String videoId;
  final List<String> keywords;
  final String rewardType;
  final Map<String, dynamic> rewardConfig;
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
  final TaskInstructionModel? instruction;
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
    String? videoId,
    this.keywords = const [],
    this.rewardType = 'target',
    this.rewardConfig = const {},
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
    this.instruction,
  })  : taskType = taskType ?? category ?? 'VIDEO',
        sourceUrl = sourceUrl ?? youtubeUrl ?? '',
        rewardCash = rewardCash ?? rewardFiat ?? 0.0,
        requiredWatchSeconds = requiredWatchSeconds ??
            (durationMinutes != null ? durationMinutes * 60 : 300),
        videoId = videoId ?? '',
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
  String get searchKeywords =>
      instruction?.searchQuery ?? _customSearchKeywords ?? (keywords.isNotEmpty ? keywords.first : title);

  /// Reward Summary formatted string
  String get rewardSummary {
    if (rewardType == 'per_time') {
      final coins = rewardConfig['coins_per_interval'] ?? rewardConfig['coins'] ?? rewardCoins;
      final seconds = rewardConfig['interval_seconds'] ?? rewardConfig['seconds'] ?? requiredWatchSeconds;
      return '+$coins coins / ${seconds}s';
    } else if (rewardType == 'watch_all') {
      final coins = rewardConfig['coins'] ?? rewardCoins;
      return '+$coins coins (Full Watch)';
    } else if (rewardType == 'target') {
      final coins = rewardConfig['coins'] ?? rewardCoins;
      final targetSec = rewardConfig['target_seconds'] ?? requiredWatchSeconds;
      return '+$coins coins for ${targetSec}s';
    }
    return '+$rewardCoins coins';
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Extract videoId from URL if not explicitly provided
    String vid = json['video_id']?.toString() ?? '';
    final url = json['source_url']?.toString() ?? json['youtube_url']?.toString() ?? '';
    if (vid.isEmpty && url.isNotEmpty) {
      final regExp = RegExp(
        r'(?:https?:\/\/)?(?:www\.|m\.)?(?:youtube\.com\/(?:watch\?(?:.*&)?v=|embed\/|v\/|shorts\/)|youtu\.be\/)([\w-]{11})',
        caseSensitive: false,
      );
      final match = regExp.firstMatch(url);
      if (match != null) {
        vid = match.group(1) ?? '';
      }
    }

    // Parse keywords
    List<String> kw = [];
    if (json['keywords'] is List) {
      kw = (json['keywords'] as List).map((e) => e.toString()).toList();
    }

    // Parse instruction
    TaskInstructionModel? instr;
    if (json['instruction'] is Map<String, dynamic>) {
      instr = TaskInstructionModel.fromJson(json['instruction'] as Map<String, dynamic>);
    } else if (kw.isNotEmpty || json['title'] != null) {
      final title = json['title']?.toString() ?? '';
      final query = kw.isNotEmpty ? kw.first : title;
      instr = TaskInstructionModel(
        searchQuery: query,
        fullInstruction:
            '1. Tap Start Task to open YouTube.\n2. Copy and paste "$query" into search.\n3. Locate "$title" and watch to receive coins!',
        title: title,
        thumbnailUrl: json['thumbnail_url']?.toString() ?? (vid.isNotEmpty ? 'https://img.youtube.com/vi/$vid/hqdefault.jpg' : ''),
      );
    }

    // Parse reward config
    Map<String, dynamic> rConfig = {};
    if (json['reward_config'] is Map) {
      rConfig = Map<String, dynamic>.from(json['reward_config'] as Map);
    }

    final coins = (json['reward_coins'] as num?)?.toInt() ??
        int.tryParse(json['reward_coins']?.toString() ?? '') ??
        (rConfig['coins'] as num?)?.toInt() ??
        100;

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
      thumbnailUrl: json['thumbnail_url']?.toString() ??
          (vid.isNotEmpty ? 'https://img.youtube.com/vi/$vid/hqdefault.jpg' : ''),
      sourceUrl: url,
      sourcePlatform: json['source_platform']?.toString() ?? 'YouTube',
      channelName: json['channel_name']?.toString() ?? '',
      videoId: vid,
      keywords: kw,
      rewardType: json['reward_type']?.toString() ?? 'target',
      rewardConfig: rConfig,
      rewardCoins: coins,
      rewardCash: json['reward_cash'] is num
          ? (json['reward_cash'] as num).toDouble()
          : double.tryParse(json['reward_cash']?.toString() ?? '0') ?? 0.0,
      rewardXp: (json['reward_xp'] as num?)?.toInt() ?? 25,
      requiredWatchSeconds: (json['required_watch_seconds'] as num?)?.toInt() ??
          (rConfig['target_seconds'] as num?)?.toInt() ??
          ((json['duration_minutes'] as num?)?.toInt() != null
              ? (json['duration_minutes'] as num).toInt() * 60
              : 300),
      quizRequired: json['quiz_required'] as bool? ?? false,
      quizPassPercentage: (json['quiz_pass_percentage'] as num?)?.toInt() ?? 70,
      minimumLevel: (json['minimum_level'] as num?)?.toInt() ?? 1,
      minimumTrustScore: (json['minimum_trust_score'] as num?)?.toInt() ?? 50,
      verificationRequired: json['verification_required'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      instruction: instr,
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
      'video_id': videoId,
      'keywords': keywords,
      'reward_type': rewardType,
      'reward_config': rewardConfig,
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
      'is_completed': isCompleted,
      'instruction': instruction?.toJson(),
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
    String? videoId,
    List<String>? keywords,
    String? searchKeywords,
    String? rewardType,
    Map<String, dynamic>? rewardConfig,
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
    TaskInstructionModel? instruction,
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
      videoId: videoId ?? this.videoId,
      keywords: keywords ?? this.keywords,
      searchKeywords: searchKeywords ?? _customSearchKeywords,
      rewardType: rewardType ?? this.rewardType,
      rewardConfig: rewardConfig ?? this.rewardConfig,
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
      instruction: instruction ?? this.instruction,
    );
  }
}

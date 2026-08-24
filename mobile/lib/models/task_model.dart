/// Local Task Model representing a verified YouTube viewing task.
class TaskModel {
  final String id;
  final String title;
  final String channelName;
  final String description;
  final String thumbnailUrl;
  final String youtubeUrl;
  final String searchKeywords;
  final int rewardCoins;
  final double rewardFiat;
  final int durationMinutes;
  final String category;
  final bool isCompleted;
  final List<String> instructions;

  const TaskModel({
    required this.id,
    required this.title,
    required this.channelName,
    required this.description,
    required this.thumbnailUrl,
    required this.youtubeUrl,
    required this.searchKeywords,
    required this.rewardCoins,
    required this.rewardFiat,
    required this.durationMinutes,
    required this.category,
    this.isCompleted = false,
    this.instructions = const [
      'Open the in-app player and allow playback to start.',
      'Watch the video continuously without skipping or fast-forwarding.',
      'Keep the video in view for the entire designated duration.',
      'Reward coins will be instantly verified and credited upon completion.',
    ],
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? channelName,
    String? description,
    String? thumbnailUrl,
    String? youtubeUrl,
    String? searchKeywords,
    int? rewardCoins,
    double? rewardFiat,
    int? durationMinutes,
    String? category,
    bool? isCompleted,
    List<String>? instructions,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      channelName: channelName ?? this.channelName,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      rewardFiat: rewardFiat ?? this.rewardFiat,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      instructions: instructions ?? this.instructions,
    );
  }
}

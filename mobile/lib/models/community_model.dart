/// Model representing community posts and discussion threads
class CommunityPostModel {
  final String id;
  final String authorName;
  final String authorTier;
  final String? authorAvatarUrl;
  final String content;
  final String categoryTag;
  final int likesCount;
  final int commentsCount;
  final String timeAgo;
  final bool isLiked;

  const CommunityPostModel({
    required this.id,
    required this.authorName,
    required this.authorTier,
    this.authorAvatarUrl,
    required this.content,
    required this.categoryTag,
    required this.likesCount,
    required this.commentsCount,
    required this.timeAgo,
    this.isLiked = false,
  });
}

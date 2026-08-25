import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/layout/app_header.dart';
import '../../../core/widgets/cards/community_card.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../services/dummy_data_service.dart';

/// Screen showcasing community discussions, creator hub spotlight, and earning tips.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedTag = 'All';

  final List<String> _tags = [
    'All',
    'Earning Tips',
    'Creator Spotlight',
    'Announcements',
  ];

  @override
  Widget build(BuildContext context) {
    final posts = _selectedTag == 'All'
        ? DummyDataService.communityPosts
        : DummyDataService.communityPosts
            .where((p) => p.categoryTag == _selectedTag)
            .toList();

    return Scaffold(
      appBar: const AppHeader(
        title: 'VEWRA Community Hub',
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.primary,
              content: Text('New Community Post modal (Phase 1 Template)'),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
        label: const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPaddingH,
          vertical: AppConstants.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Creator & Community Banner
            AppCard(
              variant: AppCardVariant.gradient,
              padding: const EdgeInsets.all(AppConstants.space16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.space10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.groups_rounded, size: 24, color: AppColors.primaryLight),
                  ),
                  const SizedBox(width: AppConstants.space12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect with Global Earners',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Share task strategies, video feedback, and discover verified creator campaigns.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.space20),

            // Tag Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tags.map((tag) {
                  final bool isSelected = _selectedTag == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppConstants.space8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(tag),
                      onSelected: (_) => setState(() => _selectedTag = tag),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppConstants.borderRadiusFull,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppConstants.space20),

            // Post Feeds
            Text(
              'Discussions & Posts (${posts.length})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppConstants.space12),

            ...posts.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.space12),
                child: CommunityCard(
                  authorName: post.authorName,
                  authorTier: post.authorTier,
                  content: post.content,
                  categoryTag: post.categoryTag,
                  likesCount: post.likesCount,
                  commentsCount: post.commentsCount,
                  timeAgo: post.timeAgo,
                  isLiked: post.isLiked,
                  onLike: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Liked post! (Simulated)'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 60), // FAB spacing
          ],
        ),
      ),
    );
  }
}

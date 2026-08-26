import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/feedback/app_empty_state.dart';
import '../providers/task_feed_provider.dart';
import '../widgets/task_card.dart';

/// Live Task & Earning Discovery screen connected to PostgreSQL catalogue.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _categories = const [
    {'label': 'All Tasks', 'value': 'ALL'},
    {'label': 'Video Tasks', 'value': 'VIDEO'},
    {'label': 'Surveys', 'value': 'SURVEY'},
    {'label': 'Social Tasks', 'value': 'SOCIAL'},
    {'label': 'Challenges', 'value': 'CHALLENGE'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String value) {
    ref.read(taskCategoryFilterProvider.notifier).state = value;
    ref.read(taskFeedProvider.notifier).loadTasks();
  }

  void _onSearchChanged(String query) {
    ref.read(taskSearchQueryProvider.notifier).state = query.trim();
    ref.read(taskFeedProvider.notifier).loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(taskFeedProvider);
    final selectedFilter = ref.watch(taskCategoryFilterProvider);

    return Column(
      children: [
        Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.space16,
                AppConstants.space12,
                AppConstants.space16,
                AppConstants.space12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earn & Tasks',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space12),
                  // Search Input
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search tasks by keyword or channel...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textTertiary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.space16,
                        vertical: AppConstants.space12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Category Filter Pills
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.space16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat['value'] == selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppConstants.space8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        cat['label']!,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusFull),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      onSelected: (_) => _onCategorySelected(cat['value']!),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppConstants.space12),
            // Live Task Feed List
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () => ref.read(taskFeedProvider.notifier).refresh(),
                child: Builder(
                  builder: (context) {
                    if (feedState.isLoading && feedState.tasks.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (feedState.errorMessage != null &&
                        feedState.tasks.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.space24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: AppColors.error, size: 48),
                              const SizedBox(height: AppConstants.space16),
                              Text(
                                'Unable to load tasks',
                                style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: AppConstants.space8),
                              Text(
                                feedState.errorMessage!,
                                textAlign: TextAlign.center,
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: AppConstants.space16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Try Again'),
                                onPressed: () => ref
                                    .read(taskFeedProvider.notifier)
                                    .refresh(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (feedState.tasks.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 60),
                          AppEmptyState(
                            icon: Icons.task_alt_rounded,
                            title: 'No Tasks Available',
                            description:
                                'No matching earning tasks found in the catalog right now. Check back soon!',
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.space16,
                        vertical: AppConstants.space8,
                      ),
                      itemCount: feedState.tasks.length,
                      itemBuilder: (context, index) {
                        final task = feedState.tasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppConstants.space12),
                          child: TaskCard(
                            task: task,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.taskDetails,
                                arguments: task,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
  }
}

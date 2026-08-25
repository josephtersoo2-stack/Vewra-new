import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../../services/dummy_data_service.dart';
import '../../../models/task_model.dart';
import '../../../core/widgets/feedback/app_empty_state.dart';
import '../widgets/task_card.dart';

/// Task & Earning Discovery screen with Video Tasks, Surveys, Social Tasks, and Challenges.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TaskModel> get _filteredTasks {
    return DummyDataService.tasks.where((task) {
      final matchesCategory = _selectedCategory == 'All' || task.category == _selectedCategory;
      final query = _searchController.text.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.channelName.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = DummyDataService.taskCategories;
    final tasks = _filteredTasks;

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
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search tasks by keyword or channel...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
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
        // Category Pills (Video Tasks, Surveys, Social Tasks, Challenges)
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.space8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat);
                    }
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryLight : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppConstants.borderRadiusFull,
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.space12),
        // Task List
        Expanded(
          child: tasks.isEmpty
              ? AppEmptyState(
                  icon: Icons.search_off_rounded,
                  title: AppStrings.emptyTasksTitle,
                  description: 'No tasks found matching "$_selectedCategory". Try choosing another category.',
                  actionText: 'Reset Filters',
                  onAction: () {
                    setState(() {
                      _selectedCategory = 'All';
                      _searchController.clear();
                    });
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.space16,
                    AppConstants.space8,
                    AppConstants.space16,
                    AppConstants.space32,
                  ),
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppConstants.space16),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskCard(
                      task: task,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.taskDetails,
                        arguments: task,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

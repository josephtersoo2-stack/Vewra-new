import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/models/task_model.dart';
import 'youtube_browser_screen.dart';

/// In-App Browser Screen delegating to the specialized YouTubeBrowserScreen.
class BrowserScreen extends ConsumerWidget {
  final TaskModel? task;
  final String? initialSessionId;
  final String? initialWatchToken;
  final bool isTestMode;

  const BrowserScreen({
    super.key,
    this.task,
    this.initialSessionId,
    this.initialWatchToken,
    this.isTestMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveTask = task ??
        const TaskModel(
          id: 'placeholder',
          title: 'YouTube Video Task',
          rewardCoins: 100,
          requiredWatchSeconds: 300,
        );

    return YouTubeBrowserScreen(
      task: effectiveTask,
      initialSessionId: initialSessionId,
      initialWatchToken: initialWatchToken,
      isTestMode: isTestMode,
    );
  }
}

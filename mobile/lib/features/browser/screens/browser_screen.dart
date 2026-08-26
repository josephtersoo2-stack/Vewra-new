import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../models/task_model.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../widgets/browser_top_bar.dart';
import '../widgets/tracking_hud.dart';
import '../widgets/task_completion_dialog.dart';
import '../providers/tracking_session_provider.dart';

/// In-App Player & Browser screen driven by server-authoritative watch session tracking.
class BrowserScreen extends ConsumerStatefulWidget {
  final TaskModel? task;

  const BrowserScreen({
    super.key,
    this.task,
  });

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen>
    with WidgetsBindingObserver {
  late TaskModel _task;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _task = widget.task ??
        const TaskModel(
          id: 'placeholder',
          title: 'Video Task Session',
          rewardCoins: 20,
        );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final notifier = ref.read(trackingSessionProvider.notifier);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      notifier.onAppBackground();
    } else if (state == AppLifecycleState.resumed) {
      notifier.onAppForeground();
    }
  }

  void _togglePlayback() {
    final state = ref.read(trackingSessionProvider);
    final notifier = ref.read(trackingSessionProvider.notifier);
    if (state.isActive) {
      notifier.pause();
    } else {
      notifier.play();
    }
  }

  Future<void> _handleComplete() async {
    setState(() => _isVerifying = true);
    final notifier = ref.read(trackingSessionProvider.notifier);
    final result = await notifier.verifyCompletion();
    setState(() => _isVerifying = false);

    if (!mounted || result == null) return;

    if (result.isCompleted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => TaskCompletionDialog(
          result: result,
          onDismiss: () {
            Navigator.pop(ctx);
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.tasks,
              (route) => false,
            );
          },
        ),
      );
    } else if (result.isAwaitingQuiz) {
      final attemptId = result.attemptId ??
          ref.read(trackingSessionProvider).session?.attemptId ??
          '';
      Navigator.pushNamed(
        context,
        AppRoutes.quiz,
        arguments: attemptId,
      );
    } else if (result.isIncomplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _handleExit() {
    final trackingState = ref.read(trackingSessionProvider);
    if (trackingState.isActive || trackingState.isPaused) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Text('Leave Session?'),
          content: const Text(
            'Exiting now will pause or abandon your current watch progress.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Continue Watching'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(trackingSessionProvider.notifier).abandonSession();
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Exit Task'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingSessionProvider);
    final creditedSeconds = trackingState.creditedWatchSeconds;
    final targetSeconds = trackingState.requiredSeconds > 0
        ? trackingState.requiredSeconds
        : (_task.requiredWatchSeconds > 0 ? _task.requiredWatchSeconds : 60);

    final isSatisfied = trackingState.isWatchSatisfied ||
        creditedSeconds >= targetSeconds;

    return AppScaffold(
      body: Column(
        children: [
          // Browser Top Bar
          BrowserTopBar(
            url: _task.sourceUrl.isNotEmpty
                ? _task.sourceUrl
                : 'https://m.youtube.com/watch?v=task',
            onClose: _handleExit,
          ),
          // Server-Authoritative Tracking HUD
          TrackingHud(
            currentSeconds: creditedSeconds,
            targetSeconds: targetSeconds,
            rewardCoins: _task.rewardCoins,
            isTracking: trackingState.isActive,
            quizRequired: _task.quizRequired,
            progressPercentage: trackingState.progressPercentage,
          ),
          // Player Container
          Expanded(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.youtubeRed.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            trackingState.isActive
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            size: 54,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppConstants.space16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.space24),
                          child: Text(
                            _task.title,
                            textAlign: TextAlign.center,
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _task.channelName.isNotEmpty
                              ? _task.channelName
                              : 'VEWRA Verified Content',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: AppConstants.space20),
                        // Play / Pause Toggle Button
                        OutlinedButton.icon(
                          onPressed: _togglePlayback,
                          icon: Icon(
                            trackingState.isActive
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                          label: Text(
                            trackingState.isActive
                                ? 'Pause Playback'
                                : 'Resume Playback',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusFull),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Verification Action Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.space16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    key: const Key('verify_task_button'),
                    text: isSatisfied
                        ? (_task.quizRequired
                            ? 'Proceed to Quiz'
                            : 'Verify & Claim Reward')
                        : 'Watching in Progress ($creditedSeconds/${targetSeconds}s)',
                    isLoading: _isVerifying,
                    prefixIcon: isSatisfied
                        ? (_task.quizRequired
                            ? const Icon(Icons.quiz_outlined,
                                color: Colors.white, size: 20)
                            : const Icon(Icons.verified_rounded,
                                color: Colors.white, size: 20))
                        : const Icon(Icons.timer_outlined,
                            color: Colors.white, size: 20),
                    onPressed: isSatisfied && !_isVerifying
                        ? _handleComplete
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

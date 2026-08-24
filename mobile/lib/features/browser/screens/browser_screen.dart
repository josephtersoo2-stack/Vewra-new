import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/task_model.dart';
import '../../../services/dummy_data_service.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../widgets/browser_top_bar.dart';
import '../widgets/tracking_hud.dart';

/// Browser Screen with top HUD, WebView container placeholder, and verification control.
class BrowserScreen extends StatefulWidget {
  final TaskModel? task;

  const BrowserScreen({
    super.key,
    this.task,
  });

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late TaskModel _task;
  int _currentSeconds = 35;
  late int _targetSeconds;
  bool _isTracking = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _task = widget.task ?? DummyDataService.tasks.first;
    _targetSeconds = _task.durationMinutes * 60;

    // Simulate progress ticker for UI inspection
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTracking && _currentSeconds < _targetSeconds) {
        setState(() {
          _currentSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
    });
  }

  void _handleComplete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: AppConstants.borderRadiusLg,
          side: BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.coinGold, size: 28),
            const SizedBox(width: 10),
            Text('Task Verified!', style: AppTypography.headlineSmall),
          ],
        ),
        content: Text(
          'Congratulations! You earned ${_task.rewardCoins} Coins. Your balance has been updated.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Exit browser
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Back to Tasks'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          // Browser Address Bar
          BrowserTopBar(
            url: _task.youtubeUrl,
            onClose: () => Navigator.pop(context),
            onReload: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reloading session viewer...')),
              );
            },
          ),
          // Tracking Heads-Up Display
          TrackingHud(
            currentSeconds: _currentSeconds,
            targetSeconds: _targetSeconds,
            rewardCoins: _task.rewardCoins,
            isTracking: _isTracking,
          ),
          // WebView Container Placeholder
          Expanded(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  // Simulated Video Player Frame
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.youtubeRed.withValues(alpha: 0.9),
                            borderRadius: AppConstants.borderRadiusMd,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.youtubeRed.withValues(alpha: 0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: AppConstants.space20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.space32),
                          child: Text(
                            _task.title,
                            textAlign: TextAlign.center,
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.space8),
                        Text(
                          _task.channelName,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppConstants.space24),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: AppConstants.space32),
                          padding: const EdgeInsets.all(AppConstants.space12),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.8),
                            borderRadius: AppConstants.borderRadiusSm,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.secondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'WebView Integration Slot (Phase 5 Engine)',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Control Footer
          Container(
            padding: const EdgeInsets.all(AppConstants.space16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AppButton(
                    text: _isTracking ? AppStrings.pauseTracking : AppStrings.resumeTracking,
                    onPressed: _toggleTracking,
                    variant: AppButtonVariant.secondary,
                    prefixIcon: Icon(
                      _isTracking ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.space12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    key: const Key('complete_verification_button'),
                    text: AppStrings.completeVerification,
                    onPressed: _handleComplete,
                    variant: AppButtonVariant.primary,
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

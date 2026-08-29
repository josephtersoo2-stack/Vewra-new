import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/routing/app_routes.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/providers/task_feed_provider.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../models/watch_session_model.dart';
import '../providers/tracking_session_provider.dart';
import '../tracking/youtube_js_tracker.dart';
import '../widgets/reward_celebration_dialog.dart';
import '../widgets/tracking_hud_overlay.dart';

/// Real In-App YouTube Browser with JavaScript event tracking, Google Login verification,
/// target video lock-on, and backend heartbeat integration.
class YouTubeBrowserScreen extends ConsumerStatefulWidget {
  final TaskModel task;
  final String? initialSessionId;
  final String? initialWatchToken;
  final bool isTestMode;

  const YouTubeBrowserScreen({
    super.key,
    required this.task,
    this.initialSessionId,
    this.initialWatchToken,
    this.isTestMode = false,
  });

  @override
  ConsumerState<YouTubeBrowserScreen> createState() => _YouTubeBrowserScreenState();
}

class _YouTubeBrowserScreenState extends ConsumerState<YouTubeBrowserScreen>
    with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  double _loadingProgress = 0.0;

  bool _isGoogleLoggedIn = false;
  bool _isPlaying = false;
  bool _isTargetDetected = false;
  double _totalWatchedSeconds = 0.0;
  bool _isCompleted = false;
  bool _hasShownCelebration = false;

  // Interval toast notification state
  bool _showToast = false;
  String _toastMessage = '';
  int _lastRewardedIntervalCount = 0;
  Timer? _toastDismissTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.task.isCompleted) {
      _isCompleted = true;
      _hasShownCelebration = true;
      _isGoogleLoggedIn = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initBackendTrackingSession();
      });
    }
  }

  @override
  void dispose() {
    _toastDismissTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _triggerIntervalToast(String message) {
    _toastDismissTimer?.cancel();
    setState(() {
      _toastMessage = message;
      _showToast = true;
    });
    _toastDismissTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _showToast = false;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.task.isCompleted) return;
    final notifier = ref.read(trackingSessionProvider.notifier);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      notifier.onAppBackground();
    } else if (state == AppLifecycleState.resumed) {
      notifier.onAppForeground();
    }
  }

  Future<void> _initBackendTrackingSession() async {
    if (widget.task.isCompleted) return;
    try {
      final repo = ref.read(taskRepositoryProvider);
      final result = await repo.startTask(widget.task.id);
      final watchSession = result['watch_session'] as WatchSessionModel?;
      if (watchSession != null && watchSession.watchToken != null) {
        final sessionWithTaskMeta = watchSession.copyWith(
          rewardType: widget.task.rewardType,
          rewardCoins: widget.task.rewardCoins,
          requiredSeconds: widget.task.requiredWatchSeconds > 0
              ? widget.task.requiredWatchSeconds
              : watchSession.requiredSeconds,
        );
        ref.read(trackingSessionProvider.notifier).initializeSession(
              session: sessionWithTaskMeta,
              watchToken: watchSession.watchToken!,
            );
      }
    } catch (_) {}
  }

  void _handleTrackerMessage(List<dynamic> args) {
    if (args.isEmpty || widget.task.isCompleted) return;
    final payload = args[0];
    if (payload is! Map) return;

    final eventType = payload['eventType']?.toString() ?? '';
    final videoId = payload['videoId']?.toString();
    final isGoogleLoggedIn = payload['isGoogleLoggedIn'] as bool? ?? true;
    final isPlaying = payload['isPlaying'] as bool? ?? false;

    setState(() {
      _isGoogleLoggedIn = isGoogleLoggedIn;
    });

    if (eventType == 'search_query_detected') {
      final query = payload['query']?.toString().toLowerCase() ?? '';
      if (query.isNotEmpty) {
        final matchKeywords = widget.task.keywords.any((k) => query.contains(k.toLowerCase()) || k.toLowerCase().contains(query));
        final matchSearch = widget.task.searchKeywords.isNotEmpty && (query.contains(widget.task.searchKeywords.toLowerCase()) || widget.task.searchKeywords.toLowerCase().contains(query));
        if (matchKeywords || matchSearch) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎯 Search keyword matched! Find and tap "${widget.task.title}" to begin verified watch earning.'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    // Check if detected video matches task
    final targetVideoId = widget.task.videoId.isNotEmpty
        ? widget.task.videoId
        : widget.task.id;

    final hasVideoId = videoId != null && videoId.isNotEmpty;
    final matchesTarget = hasVideoId && targetVideoId.isNotEmpty &&
        (videoId == targetVideoId ||
            widget.task.sourceUrl.contains(videoId) ||
            targetVideoId.contains(videoId));

    if (matchesTarget && !_isTargetDetected) {
      setState(() => _isTargetDetected = true);
    } else if (hasVideoId && !matchesTarget && _isTargetDetected) {
      setState(() => _isTargetDetected = false);
      ref.read(trackingSessionProvider.notifier).pause();
    }

    final effectivePlaying = eventType == 'play' || (eventType == 'timeupdate' && isPlaying) || (eventType == 'video_detected' && isPlaying);
    if (eventType == 'play') {
      setState(() => _isPlaying = true);
    } else if (eventType == 'pause' || eventType == 'ended') {
      setState(() => _isPlaying = false);
    } else if (eventType == 'timeupdate') {
      setState(() => _isPlaying = isPlaying);
    }

    final playbackPos = (payload['currentTime'] as num?)?.toDouble();

    // Active watch tracking: target video detected and playing
    if (_isTargetDetected && (_isPlaying || effectivePlaying)) {
      ref.read(trackingSessionProvider.notifier).play(playbackPosition: playbackPos);
    } else if (!_isPlaying && !effectivePlaying) {
      ref.read(trackingSessionProvider.notifier).pause(playbackPosition: playbackPos);
    }

    // Check completion condition
    final trackingState = ref.read(trackingSessionProvider);
    final isIntervalTask = widget.task.rewardType == 'per_time';
    final targetSec = widget.task.requiredWatchSeconds > 0
        ? widget.task.requiredWatchSeconds.toDouble()
        : (isIntervalTask ? 60.0 : 300.0);

    final currentWatched = trackingState.creditedWatchSeconds > 0
        ? trackingState.creditedWatchSeconds.toDouble()
        : _totalWatchedSeconds;

    if (isIntervalTask) {
      final interval = targetSec > 0 ? targetSec : 60.0;
      final currentIntervalCount = (currentWatched / interval).floor();
      if (currentIntervalCount > _lastRewardedIntervalCount) {
        _lastRewardedIntervalCount = currentIntervalCount;
        final coinsAdded = widget.task.rewardCoins;
        final totalCoins = currentIntervalCount * coinsAdded;
        _triggerIntervalToast(
          '✨ +$coinsAdded Coins earned for ${Formatters.formatSeconds(interval.toInt())} watched! (Total: +$totalCoins)',
        );
        ref.read(walletProvider.notifier).loadWalletData(forceRefresh: true);
      }

      // Complete only if the video naturally ended
      if (eventType == 'ended' && !_isCompleted && _lastRewardedIntervalCount > 0) {
        setState(() {
          _isCompleted = true;
        });
        _triggerCompletion();
      }
    } else {
      // Threshold or Watch All Task
      if (currentWatched >= targetSec && !_isCompleted) {
        setState(() {
          _isCompleted = true;
        });
        _triggerCompletion();
      }
    }
  }

  void _triggerCompletion() {
    if (_hasShownCelebration || widget.task.isCompleted) return;
    _hasShownCelebration = true;

    final trackingState = ref.read(trackingSessionProvider);
    ref.read(walletProvider.notifier).loadWalletData(forceRefresh: true);

    final isIntervalTask = widget.task.rewardType == 'per_time';
    final totalCoinsEarned = isIntervalTask
        ? max(widget.task.rewardCoins, _lastRewardedIntervalCount * widget.task.rewardCoins)
        : widget.task.rewardCoins;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RewardCelebrationDialog(
        taskTitle: widget.task.title,
        coinsEarned: totalCoinsEarned,
        xpEarned: widget.task.rewardXp,
        requiresQuiz: widget.task.quizRequired,
        onContinue: () {
          Navigator.pop(context); // Dismiss dialog
          if (widget.task.quizRequired) {
            final attemptId = trackingState.session?.attemptId ?? widget.task.id;
            Navigator.pushNamed(
              context,
              AppRoutes.quiz,
              arguments: {
                'attemptId': attemptId,
                'taskTitle': widget.task.title,
                'rewardCoins': totalCoinsEarned,
              },
            );
          } else {
            Navigator.pop(context); // Return to task catalog
          }
        },
      ),
    );
  }

  // Web / Test Simulator Fallback
  Widget _buildWebSimulatorView() {
    final trackingState = ref.watch(trackingSessionProvider);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: AppConstants.borderRadiusLg,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.play_rectangle_fill, color: AppColors.youtubeRed, size: 60),
            const SizedBox(height: 16),
            Text(widget.task.title, style: AppTypography.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Interactive YouTube Simulator (Testing Environment)',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final notifier = ref.read(trackingSessionProvider.notifier);
                    if (trackingState.isActive) {
                      notifier.pause();
                      setState(() => _isPlaying = false);
                    } else {
                      notifier.play();
                      setState(() {
                        _isPlaying = true;
                        _isTargetDetected = true;
                      });
                    }
                  },
                  icon: Icon(trackingState.isActive ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill),
                  label: Text(trackingState.isActive ? 'Pause' : 'Play / Simulate Watch'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _isTestEnv =>
      kIsWeb || widget.isTestMode || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS);

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingSessionProvider);
    final isFreeWatch = widget.task.isCompleted || _isCompleted;

    final initialUrl = isFreeWatch && (widget.task.sourceUrl.isNotEmpty || widget.task.videoId.isNotEmpty)
        ? (widget.task.sourceUrl.isNotEmpty
            ? widget.task.sourceUrl
            : 'https://m.youtube.com/watch?v=${widget.task.videoId}')
        : 'https://m.youtube.com';

    final effectiveWatched = trackingState.creditedWatchSeconds > 0
        ? trackingState.creditedWatchSeconds.toDouble()
        : _totalWatchedSeconds;

    final isIntervalTask = widget.task.rewardType == 'per_time';
    final targetSec = widget.task.requiredWatchSeconds > 0
        ? widget.task.requiredWatchSeconds
        : 60;
    final effectiveCoins = isIntervalTask
        ? (effectiveWatched ~/ targetSec) * widget.task.rewardCoins.toDouble()
        : (trackingState.isCompleted || _isCompleted ? widget.task.rewardCoins.toDouble() : 0.0);

    // Continuous interval reward observer: triggers toast & updates wallet the instant milestone is reached
    ref.listen<TrackingSessionState>(trackingSessionProvider, (previous, next) {
      if (!mounted || widget.task.isCompleted || _isCompleted) return;
      final isIntervalTask = widget.task.rewardType == 'per_time';
      if (isIntervalTask) {
        final interval = widget.task.requiredWatchSeconds > 0
            ? widget.task.requiredWatchSeconds
            : 60;
        final currentIntervalCount = next.creditedWatchSeconds ~/ interval;
        if (currentIntervalCount > _lastRewardedIntervalCount && currentIntervalCount > 0) {
          _lastRewardedIntervalCount = currentIntervalCount;
          final coinsAdded = widget.task.rewardCoins;
          final totalCoins = currentIntervalCount * coinsAdded;
          _triggerIntervalToast(
            '✨ +$coinsAdded Coins earned for ${Formatters.formatSeconds(interval)} watched! (Total: +$totalCoins)',
          );
          ref.read(walletProvider.notifier).loadWalletData(forceRefresh: true);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isFreeWatch
              ? (widget.task.title.isNotEmpty ? widget.task.title : 'YouTube Video')
              : (_isTargetDetected ? '🎯 Locked on Target Video' : 'YouTube Browser'),
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!isFreeWatch)
            IconButton(
              icon: const Icon(CupertinoIcons.doc_on_doc, size: 20),
              tooltip: 'Copy Search Phrase',
              onPressed: () {
                final phrase = widget.task.searchKeywords;
                Clipboard.setData(ClipboardData(text: phrase));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Search phrase copied: "$phrase"'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(CupertinoIcons.refresh, size: 20),
            tooltip: 'Reload Page',
            onPressed: () => _webViewController?.reload(),
          ),
        ],
        bottom: _loadingProgress < 1.0 && !_isTestEnv
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: Colors.transparent,
                  color: AppColors.primary,
                  minHeight: 2,
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          if (_isTestEnv)
            _buildWebSimulatorView()
          else
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(initialUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                isElementFullscreenEnabled: true,
                supportMultipleWindows: true,
                thirdPartyCookiesEnabled: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                saveFormData: true,
                sharedCookiesEnabled: true,
                userAgent:
                    'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36',
              ),
              initialUserScripts: UnmodifiableListView<UserScript>([
                UserScript(
                  source: YouTubeJsTracker.trackingScript,
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                ),
                UserScript(
                  source: YouTubeJsTracker.trackingScript,
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                ),
              ]),
              onWebViewCreated: (controller) {
                _webViewController = controller;
                controller.addJavaScriptHandler(
                  handlerName: 'YouTubeTracker',
                  callback: _handleTrackerMessage,
                );
              },
              onLoadStop: (controller, url) async {
                setState(() => _loadingProgress = 1.0);
                await controller.evaluateJavascript(source: YouTubeJsTracker.trackingScript);
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _loadingProgress = progress / 100.0;
                });
              },
            ),

          // Google Login Required Banner (Only during active earning sessions)
          if (!isFreeWatch && !_isGoogleLoggedIn && !kIsWeb)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFD97706),
                  boxShadow: [
                    BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Login Required',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Sign in to YouTube to earn coins from verified watch time.',
                            style: AppTypography.labelSmall.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        _webViewController?.loadUrl(
                          urlRequest: URLRequest(
                            url: WebUri(
                              'https://accounts.google.com/ServiceLogin?service=youtube&continue=https://m.youtube.com',
                            ),
                          ),
                        );
                      },
                      child: const Text('Sign In', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ),

          // Floating Tracking HUD Overlay (Only rendered for uncompleted earning tasks)
          if (!isFreeWatch)
            TrackingHudOverlay(
              task: widget.task,
              isTargetDetected: _isTargetDetected,
              isTracking: trackingState.isActive || _isPlaying,
              totalWatchedSeconds: effectiveWatched,
              sessionCoinsEarned: effectiveCoins,
              isCompleted: _isCompleted || trackingState.isCompleted,
              isGoogleLoggedIn: _isGoogleLoggedIn,
              onSignInTap: () {
                _webViewController?.loadUrl(
                  urlRequest: URLRequest(
                    url: WebUri(
                      'https://accounts.google.com/ServiceLogin?service=youtube&continue=https://m.youtube.com',
                    ),
                  ),
                );
              },
            ),

          // Floating Fade-in/out Interval Toast Notification (Top Layer)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _showToast ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: AnimatedSlide(
                offset: _showToast ? Offset.zero : const Offset(0, -0.4),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B4B).withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.coinGold,
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coinGold.withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.coinGold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.monetization_on_rounded,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _toastMessage,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

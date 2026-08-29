import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tracking_repository.dart';
import '../models/watch_session_model.dart';
import '../models/watch_completion_model.dart';
import '../../wallet/providers/wallet_provider.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository();
});

enum TrackingSessionStatus {
  idle,
  starting,
  active,
  paused,
  awaitingQuiz,
  verifying,
  completed,
  invalid,
  error,
}

class TrackingSessionState {
  final TrackingSessionStatus status;
  final WatchSessionModel? session;
  final int creditedWatchSeconds;
  final int requiredSeconds;
  final double progressPercentage;
  final DateTime? lastSuccessfulHeartbeat;
  final int sequence;
  final String? watchToken;
  final String? errorMessage;
  final WatchCompletionModel? completionResult;

  const TrackingSessionState({
    this.status = TrackingSessionStatus.idle,
    this.session,
    this.creditedWatchSeconds = 0,
    this.requiredSeconds = 60,
    this.progressPercentage = 0.0,
    this.lastSuccessfulHeartbeat,
    this.sequence = 1,
    this.watchToken,
    this.errorMessage,
    this.completionResult,
  });

  bool get isActive => status == TrackingSessionStatus.active;
  bool get isPaused => status == TrackingSessionStatus.paused;
  bool get isCompleted => status == TrackingSessionStatus.completed;
  bool get isAwaitingQuiz => status == TrackingSessionStatus.awaitingQuiz;
  bool get isInterval => session?.rewardType == 'per_time';
  bool get isWatchSatisfied => !isInterval && creditedWatchSeconds >= requiredSeconds;

  TrackingSessionState copyWith({
    TrackingSessionStatus? status,
    WatchSessionModel? session,
    int? creditedWatchSeconds,
    int? requiredSeconds,
    double? progressPercentage,
    DateTime? lastSuccessfulHeartbeat,
    int? sequence,
    String? watchToken,
    String? errorMessage,
    WatchCompletionModel? completionResult,
  }) {
    return TrackingSessionState(
      status: status ?? this.status,
      session: session ?? this.session,
      creditedWatchSeconds: creditedWatchSeconds ?? this.creditedWatchSeconds,
      requiredSeconds: requiredSeconds ?? this.requiredSeconds,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastSuccessfulHeartbeat:
          lastSuccessfulHeartbeat ?? this.lastSuccessfulHeartbeat,
      sequence: sequence ?? this.sequence,
      watchToken: watchToken ?? this.watchToken,
      errorMessage: errorMessage,
      completionResult: completionResult ?? this.completionResult,
    );
  }
}

class TrackingSessionNotifier extends StateNotifier<TrackingSessionState> {
  final TrackingRepository _repository;
  final Ref _ref;
  Timer? _heartbeatTimer;
  Timer? _localTickerTimer;

  TrackingSessionNotifier(this._repository, this._ref)
      : super(const TrackingSessionState());

  /// Initializes tracking state from a newly provisioned or resumed watch session.
  void initializeSession({
    required WatchSessionModel session,
    required String watchToken,
  }) {
    _stopTimer();
    state = TrackingSessionState(
      status: TrackingSessionStatus.active,
      session: session,
      creditedWatchSeconds: session.creditedWatchSeconds,
      requiredSeconds: session.requiredSeconds,
      progressPercentage: session.progressPercentage,
      sequence: session.lastSequence,
      watchToken: watchToken,
    );
    _startTimer();
    sendHeartbeat();
  }

  void _startTimer() {
    _stopTimer();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (state.isActive && !state.isWatchSatisfied) {
        sendHeartbeat();
      }
    });

    _localTickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isActive && !state.isWatchSatisfied) {
        final newSec = state.creditedWatchSeconds + 1;
        final pct = state.requiredSeconds > 0
            ? (state.isInterval
                ? (((newSec % state.requiredSeconds) / state.requiredSeconds) * 100.0).clamp(0.0, 100.0)
                : ((newSec / state.requiredSeconds) * 100.0).clamp(0.0, 100.0))
            : 100.0;
        state = state.copyWith(
          creditedWatchSeconds: newSec,
          progressPercentage: pct,
        );
      }
    });
  }

  void _stopTimer() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _localTickerTimer?.cancel();
    _localTickerTimer = null;
  }

  /// Sends periodic heartbeat with incremented sequence number.
  Future<void> sendHeartbeat({double? playbackPosition, bool isGoogleAuthenticated = true}) async {
    if (state.session == null || state.watchToken == null) return;
    if (state.status != TrackingSessionStatus.active) return;

    final nextSeq = state.sequence + 1;
    try {
      final progress = await _repository.sendHeartbeat(
        sessionId: state.session!.id,
        watchToken: state.watchToken!,
        sequence: nextSeq,
        playbackPosition: playbackPosition,
        clientTimestamp: DateTime.now(),
        isGoogleAuthenticated: isGoogleAuthenticated,
      );

      final updatedSession = state.session?.copyWith(
        creditedWatchSeconds: progress.creditedWatchSeconds,
        requiredSeconds: progress.requiredSeconds,
        progressPercentage: progress.progressPercentage,
        isSatisfied: progress.isSatisfied,
        rewardType: progress.rewardType.isNotEmpty ? progress.rewardType : state.session?.rewardType,
      );

      state = state.copyWith(
        session: updatedSession,
        sequence: nextSeq,
        creditedWatchSeconds: progress.creditedWatchSeconds,
        requiredSeconds: progress.requiredSeconds,
        progressPercentage: progress.progressPercentage,
        lastSuccessfulHeartbeat: DateTime.now(),
      );
    } catch (e) {
      // Network hiccup - preserve state, do not increment earned time locally
    }
  }

  /// Plays / Resumes video session.
  Future<void> play({double? playbackPosition}) async {
    final nextSeq = state.sequence + 1;
    state = state.copyWith(
      status: TrackingSessionStatus.active,
      sequence: nextSeq,
    );
    _startTimer();
    sendHeartbeat(playbackPosition: playbackPosition);
    if (state.session == null || state.watchToken == null) return;
    try {
      await _repository.sendEvent(
        sessionId: state.session!.id,
        watchToken: state.watchToken!,
        eventType: 'PLAY',
        sequence: nextSeq,
        playbackPosition: playbackPosition,
      );
    } catch (_) {}
  }

  /// Pauses video session.
  Future<void> pause({double? playbackPosition}) async {
    _stopTimer();
    final nextSeq = state.sequence + 1;
    state = state.copyWith(
      status: TrackingSessionStatus.paused,
      sequence: nextSeq,
    );
    if (state.session == null || state.watchToken == null) return;
    try {
      await _repository.sendEvent(
        sessionId: state.session!.id,
        watchToken: state.watchToken!,
        eventType: 'PAUSE',
        sequence: nextSeq,
        playbackPosition: playbackPosition,
      );
    } catch (_) {}
  }

  /// Handles App Background transition.
  Future<void> onAppBackground() async {
    if (state.session == null || state.watchToken == null) return;
    _stopTimer();
    final nextSeq = state.sequence + 1;
    state = state.copyWith(
      status: TrackingSessionStatus.paused,
      sequence: nextSeq,
    );
    try {
      await _repository.sendEvent(
        sessionId: state.session!.id,
        watchToken: state.watchToken!,
        eventType: 'APP_BACKGROUND',
        sequence: nextSeq,
      );
    } catch (_) {}
  }

  /// Handles App Foreground resume transition.
  Future<void> onAppForeground() async {
    if (state.session == null || state.watchToken == null) return;
    final nextSeq = state.sequence + 1;
    state = state.copyWith(
      status: TrackingSessionStatus.active,
      sequence: nextSeq,
    );
    _startTimer();
    try {
      await _repository.sendEvent(
        sessionId: state.session!.id,
        watchToken: state.watchToken!,
        eventType: 'APP_FOREGROUND',
        sequence: nextSeq,
      );
    } catch (_) {}
  }

  /// Requests server completion verification and settles rewards.
  Future<WatchCompletionModel?> verifyCompletion() async {
    if (state.session == null || state.watchToken == null) return null;
    _stopTimer();
    state = state.copyWith(status: TrackingSessionStatus.verifying);

    try {
      final result = await _repository.verifyCompletion(
        sessionId: state.session!.id,
        watchToken: state.watchToken!,
      );

      if (result.isCompleted) {
        state = state.copyWith(
          status: TrackingSessionStatus.completed,
          completionResult: result,
        );
        // Refresh wallet balance on client
        _ref.read(walletProvider.notifier).loadWalletData(forceRefresh: true);
      } else if (result.isAwaitingQuiz) {
        state = state.copyWith(
          status: TrackingSessionStatus.awaitingQuiz,
          completionResult: result,
        );
      } else {
        state = state.copyWith(
          status: TrackingSessionStatus.active,
          errorMessage: result.message,
          completionResult: result,
        );
        _startTimer();
      }
      return result;
    } catch (e) {
      state = state.copyWith(
        status: TrackingSessionStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  /// Abandons tracking session.
  Future<void> abandonSession() async {
    if (state.session == null || state.watchToken == null) return;
    _stopTimer();
    try {
      await _repository.abandonSession(
        sessionId: state.session!.id,
        watchToken: state.watchToken!,
      );
    } catch (_) {}
    state = const TrackingSessionState(status: TrackingSessionStatus.idle);
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

final trackingSessionProvider =
    StateNotifierProvider<TrackingSessionNotifier, TrackingSessionState>((ref) {
  final repo = ref.watch(trackingRepositoryProvider);
  return TrackingSessionNotifier(repo, ref);
});

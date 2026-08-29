import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API endpoint constants and environment-based configuration.
class ApiConstants {
  ApiConstants._();

  /// Resolves the base API URL dynamically from environment configuration (.env),
  /// with a robust localhost fallback.
  static String get baseUrl {
    try {
      final value = dotenv.env['API_BASE_URL']?.trim();
      if (value != null && value.isNotEmpty) {
        return value.endsWith('/')
            ? value.substring(0, value.length - 1)
            : value;
      }
    } catch (_) {
      // Graceful fallback when dotenv is not initialized (e.g., test runners)
    }
    return 'http://192.168.1.45:8000/api/v1';
  }

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Authentication Endpoints
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String logout = '/auth/logout/';
  static const String refreshToken = '/auth/refresh/';
  static const String passwordReset = '/auth/password-reset/';
  static const String passwordResetConfirm = '/auth/password-reset/confirm/';

  // User & Profile Endpoints
  static const String userProfile = '/users/profile/';
  static const String userProfileUpdate = '/users/profile/update/';
  static const String userUpdateProfileAlias = '/users/update-profile/';
  static const String userStatistics = '/users/profile/statistics/';
  static const String userPreferences = '/users/preferences/';
  static const String userPreferencesUpdate = '/users/preferences/update/';

  // Security & Verification Endpoints
  static const String verificationStatus = '/security/verification/status/';
  static const String verificationSubmit = '/security/verification/submit/';
  static const String trustHistory = '/security/trust/history/';
  static const String registerDevice = '/security/device/';

  // Subscriptions Endpoints
  static const String subscriptionPlans = '/subscriptions/plans/';
  static const String mySubscription = '/subscriptions/my-subscription/';

  // Wallet & Economy Endpoints
  static const String walletBalance = '/wallet/balance/';
  static const String walletTransactions = '/wallet/transactions/';
  static const String walletCoinsHistory = '/wallet/coins/history/';
  static const String walletCoinsTransfer = '/wallet/coins/transfer/';
  static const String walletWithdrawals = '/wallet/withdrawals/';
  static const String walletWithdrawalsCreate = '/wallet/withdrawals/create/';

  // Phase 5: Task Catalog & Attempts Endpoints
  static const String tasks = '/tasks/';
  static const String taskFetchMeta = '/tasks/fetch-meta/';
  static const String taskCreate = '/tasks/create/';
  static String taskDetails(String id) => '/tasks/$id/';
  static String taskEligibility(String id) => '/tasks/$id/eligibility/';
  static String taskStart(String id) => '/tasks/$id/start/';

  static const String taskAttempts = '/tasks/attempts/';
  static String taskAttempt(String id) => '/tasks/attempts/$id/';
  static String taskQuiz(String id) => '/tasks/attempts/$id/quiz/';
  static String taskQuizSubmit(String id) => '/tasks/attempts/$id/quiz/submit/';

  // Phase 5: Video Tracking & Heartbeat Endpoints
  static String trackingSession(String id) => '/tracking/sessions/$id/';
  static String trackingHeartbeat(String id) => '/tracking/sessions/$id/heartbeat/';
  static String trackingEvents(String id) => '/tracking/sessions/$id/events/';
  static String trackingComplete(String id) => '/tracking/sessions/$id/complete/';
  static String trackingAbandon(String id) => '/tracking/sessions/$id/abandon/';

  // Phase 5.5: Campaigns & Advertising Platform Endpoints
  static const String campaigns = '/campaigns/';
  static const String campaignCreate = '/campaigns/create/';
  static String campaignDetails(String id) => '/campaigns/$id/';
  static String campaignSubmit(String id) => '/campaigns/$id/submit/';
  static String campaignApprove(String id) => '/campaigns/$id/approve/';
  static String campaignReject(String id) => '/campaigns/$id/reject/';
  static String campaignPause(String id) => '/campaigns/$id/pause/';
  static String campaignMediaList(String campaignId) => '/campaigns/$campaignId/media/';
  static String campaignMediaUpload(String campaignId) => '/campaigns/$campaignId/media/upload/';
  static String campaignMediaDetail(String mediaId) => '/campaign-media/$mediaId/';
  static String campaignMediaRestore(String mediaId) => '/campaign-media/$mediaId/restore/';
}
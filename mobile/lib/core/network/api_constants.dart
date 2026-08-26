/// Centralized API endpoint constants and configuration.
class ApiConstants {
  ApiConstants._();

  // Base URL: In local development, Android emulator uses 10.0.2.2, iOS/Web/Desktop uses 127.0.0.1
  static const String defaultBaseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String localhostBaseUrl = 'http://127.0.0.1:8000/api/v1';

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
}

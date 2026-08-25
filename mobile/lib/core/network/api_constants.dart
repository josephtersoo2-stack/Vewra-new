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

  // User Endpoints
  static const String userProfile = '/users/profile/';
  static const String updateProfile = '/users/update-profile/';

  // Security Endpoints
  static const String verificationStatus = '/security/verification/';
  static const String registerDevice = '/security/device/';
}

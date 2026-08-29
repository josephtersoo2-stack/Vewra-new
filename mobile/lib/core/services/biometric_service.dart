import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Biometric Authentication Service for Vewra Mobile
/// Supports Fingerprint, Face ID, and device credentials with secure token retrieval.
///
/// Uses EncryptedSharedPreferences on Android for reliable persistence,
/// and a separate SharedPreferences flag for the enabled toggle so it
/// survives independently of credential storage.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // Use the SAME Android/iOS options as SecureStorageService for reliability
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _savedEmailKey = 'vewra_biometric_email';
  static const String _savedPasswordKey = 'vewra_biometric_password';

  // Use SharedPreferences for the enabled toggle — it's a non-sensitive boolean
  // that must reliably persist across app restarts and not be affected by
  // secure storage quirks.
  static const String _biometricEnabledPrefKey = 'vewra_biometrics_enabled';

  /// Check if device supports and has enrolled biometrics
  Future<bool> isBiometricsAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Get list of available biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Trigger biometric authentication prompt
  Future<bool> authenticate({
    String reason = 'Scan your fingerprint or face to sign in to Vewra',
  }) async {
    try {
      final isAvailable = await isBiometricsAvailable();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Save credentials for quick biometric sign-in and mark as enabled
  Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _savedEmailKey, value: email);
    await _storage.write(key: _savedPasswordKey, value: password);
    // Use SharedPreferences for the enabled flag — reliable and non-sensitive
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledPrefKey, true);
  }

  /// Check if biometric login is enabled by the user
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledPrefKey) ?? false;
  }

  /// Get saved credentials after successful biometric check
  Future<Map<String, String>?> getSavedCredentials() async {
    final enabled = await isBiometricEnabled();
    if (!enabled) return null;

    final email = await _storage.read(key: _savedEmailKey);
    final password = await _storage.read(key: _savedPasswordKey);

    if (email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  /// Check if biometric credentials are saved and enabled
  Future<bool> hasSavedCredentials() async {
    final enabled = await isBiometricEnabled();
    if (!enabled) return false;
    final email = await _storage.read(key: _savedEmailKey);
    return email != null && email.isNotEmpty;
  }

  /// Clear saved biometric credentials and disable biometric login
  Future<void> clearBiometricCredentials() async {
    await _storage.delete(key: _savedEmailKey);
    await _storage.delete(key: _savedPasswordKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledPrefKey, false);
  }
}

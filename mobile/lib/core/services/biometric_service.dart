import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Biometric Authentication Service for Vewra Mobile
/// Supports Fingerprint, Face ID, and device credentials with secure token retrieval.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _biometricEnabledKey = 'vewra_biometrics_enabled';
  static const String _savedEmailKey = 'vewra_biometric_email';
  static const String _savedPasswordKey = 'vewra_biometric_password';

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

  /// Save credentials for quick biometric sign-in
  Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _savedEmailKey, value: email);
    await _storage.write(key: _savedPasswordKey, value: password);
    await _storage.write(key: _biometricEnabledKey, value: 'true');
  }

  /// Get saved credentials after successful biometric check
  Future<Map<String, String>?> getSavedCredentials() async {
    final enabled = await _storage.read(key: _biometricEnabledKey);
    if (enabled != 'true') return null;

    final email = await _storage.read(key: _savedEmailKey);
    final password = await _storage.read(key: _savedPasswordKey);

    if (email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  /// Check if biometric credentials are saved
  Future<bool> hasSavedCredentials() async {
    final enabled = await _storage.read(key: _biometricEnabledKey);
    final email = await _storage.read(key: _savedEmailKey);
    return enabled == 'true' && email != null && email.isNotEmpty;
  }

  /// Clear saved biometric credentials
  Future<void> clearBiometricCredentials() async {
    await _storage.delete(key: _savedEmailKey);
    await _storage.delete(key: _savedPasswordKey);
    await _storage.delete(key: _biometricEnabledKey);
  }
}

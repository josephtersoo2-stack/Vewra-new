import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token and sensitive key-value storage service.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String _keyAccessToken = 'vewra_access_token';
  static const String _keyRefreshToken = 'vewra_refresh_token';
  static const String _keyUserId = 'vewra_user_id';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  // Access Token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // Save Token Pair
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  // User ID
  Future<void> saveUserId(String id) async {
    await _storage.write(key: _keyUserId, value: id);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  // Clear Session
  Future<void> clearAll() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserId);
  }

  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/storage/secure_storage_service.dart';

class MockFlutterSecureStorage {
  final Map<String, String> _data = {};

  Future<void> write({required String key, required String value}) async {
    _data[key] = value;
  }

  Future<String?> read({required String key}) async {
    return _data[key];
  }

  Future<void> delete({required String key}) async {
    _data.remove(key);
  }

  Future<void> deleteAll() async {
    _data.clear();
  }
}

class TestableSecureStorageService extends SecureStorageService {
  final MockFlutterSecureStorage mock = MockFlutterSecureStorage();

  @override
  Future<void> saveAccessToken(String token) async => mock.write(key: 'vewra_access_token', value: token);
  @override
  Future<String?> getAccessToken() async => mock.read(key: 'vewra_access_token');
  @override
  Future<void> saveRefreshToken(String token) async => mock.write(key: 'vewra_refresh_token', value: token);
  @override
  Future<String?> getRefreshToken() async => mock.read(key: 'vewra_refresh_token');
  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }
  @override
  Future<void> saveUserId(String id) async => mock.write(key: 'vewra_user_id', value: id);
  @override
  Future<String?> getUserId() async => mock.read(key: 'vewra_user_id');
  @override
  Future<void> clearAll() async => mock.deleteAll();
  @override
  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

void main() {
  group('SecureStorageService Unit Tests', () {
    late TestableSecureStorageService storageService;

    setUp(() {
      storageService = TestableSecureStorageService();
    });

    test('saves and retrieves access token correctly', () async {
      await storageService.saveAccessToken('sample_access_jwt');
      expect(await storageService.getAccessToken(), 'sample_access_jwt');
    });

    test('saves and retrieves refresh token correctly', () async {
      await storageService.saveRefreshToken('sample_refresh_jwt');
      expect(await storageService.getRefreshToken(), 'sample_refresh_jwt');
    });

    test('saves token pair and checks session validity', () async {
      expect(await storageService.hasValidSession(), isFalse);
      await storageService.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_123',
      );
      expect(await storageService.hasValidSession(), isTrue);
      expect(await storageService.getAccessToken(), 'access_123');
      expect(await storageService.getRefreshToken(), 'refresh_123');
    });

    test('saves and retrieves user id', () async {
      await storageService.saveUserId('usr_uuid_999');
      expect(await storageService.getUserId(), 'usr_uuid_999');
    });

    test('clearAll deletes all persisted credentials and invalidates session', () async {
      await storageService.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_123',
      );
      await storageService.saveUserId('usr_1');

      await storageService.clearAll();
      expect(await storageService.getAccessToken(), isNull);
      expect(await storageService.getRefreshToken(), isNull);
      expect(await storageService.getUserId(), isNull);
      expect(await storageService.hasValidSession(), isFalse);
    });
  });
}

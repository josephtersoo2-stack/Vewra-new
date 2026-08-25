import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/models/user_model.dart';
import 'package:vewra_mobile/features/auth/models/auth_response_model.dart';
import 'package:vewra_mobile/features/auth/data/auth_repository.dart';
import 'package:vewra_mobile/features/auth/data/auth_api_service.dart';
import 'package:vewra_mobile/core/storage/secure_storage_service.dart';

class FakeAuthApiService extends AuthApiService {
  bool shouldSucceed = true;

  @override
  Future<AuthResponseModel> login({required String email, required String password}) async {
    if (!shouldSucceed) throw Exception('Invalid email or password.');
    return const AuthResponseModel(
      status: 'success',
      message: 'Login successful.',
      tokens: AuthTokensModel(access: 'mock_access_token', refresh: 'mock_refresh_token'),
      user: UserModel(
        id: 'usr_001',
        username: 'alex_developer',
        email: 'alex.dev@vewra.io',
      ),
    );
  }

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String username,
    required String password,
    String country = 'Global',
    String phoneNumber = '',
  }) async {
    if (!shouldSucceed) throw Exception('Registration failed.');
    return AuthResponseModel(
      status: 'success',
      message: 'Account created successfully.',
      tokens: const AuthTokensModel(access: 'mock_access_token', refresh: 'mock_refresh_token'),
      user: UserModel(
        id: 'usr_new',
        username: username,
        email: email,
      ),
    );
  }

  @override
  Future<UserModel> fetchUserProfile() async {
    if (!shouldSucceed) throw Exception('Unauthorized');
    return const UserModel(
      id: 'usr_001',
      username: 'alex_developer',
      email: 'alex.dev@vewra.io',
    );
  }

  @override
  Future<void> logout({required String refreshToken}) async {}
}

class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<void> saveAccessToken(String token) async => _data['access'] = token;
  @override
  Future<String?> getAccessToken() async => _data['access'];
  @override
  Future<void> saveRefreshToken(String token) async => _data['refresh'] = token;
  @override
  Future<String?> getRefreshToken() async => _data['refresh'];
  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _data['access'] = accessToken;
    _data['refresh'] = refreshToken;
  }
  @override
  Future<void> saveUserId(String id) async => _data['user_id'] = id;
  @override
  Future<String?> getUserId() async => _data['user_id'];
  @override
  Future<void> clearAll() async => _data.clear();
  @override
  Future<bool> hasValidSession() async => _data.containsKey('access');
}

void main() {
  group('AuthRepository Unit Tests', () {
    late FakeAuthApiService fakeApiService;
    late FakeSecureStorageService fakeStorage;
    late AuthRepository repository;

    setUp(() {
      fakeApiService = FakeAuthApiService();
      fakeStorage = FakeSecureStorageService();
      repository = AuthRepository(
        apiService: fakeApiService,
        storageService: fakeStorage,
      );
    });

    test('login success saves tokens and caches user', () async {
      final user = await repository.login(email: 'alex.dev@vewra.io', password: 'password123');
      expect(user.email, 'alex.dev@vewra.io');
      expect(await fakeStorage.getAccessToken(), 'mock_access_token');
      expect(await fakeStorage.getRefreshToken(), 'mock_refresh_token');
      expect(repository.currentUser, isNotNull);
    });

    test('register success saves tokens and returns created user', () async {
      final user = await repository.register(
        email: 'newuser@vewra.io',
        username: 'newuser',
        password: 'Password123!',
      );
      expect(user.username, 'newuser');
      expect(await fakeStorage.getAccessToken(), 'mock_access_token');
    });

    test('logout clears secure storage and cached user', () async {
      await repository.login(email: 'alex.dev@vewra.io', password: 'password123');
      expect(repository.currentUser, isNotNull);

      await repository.logout();
      expect(repository.currentUser, isNull);
      expect(await fakeStorage.getAccessToken(), isNull);
    });

    test('restoreSession returns cached user if valid session exists', () async {
      await fakeStorage.saveTokens(accessToken: 'valid_token', refreshToken: 'valid_refresh');
      final user = await repository.restoreSession();
      expect(user, isNotNull);
      expect(user?.username, 'alex_developer');
    });
  });
}

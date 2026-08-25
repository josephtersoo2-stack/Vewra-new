import '../../../core/storage/secure_storage_service.dart';
import '../../../models/user_model.dart';
import 'auth_api_service.dart';

/// Repository managing authentication operations and persistent token storage.
class AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _storageService;

  UserModel? _cachedUser;

  AuthRepository({
    AuthApiService? apiService,
    SecureStorageService? storageService,
  })  : _apiService = apiService ?? AuthApiService(),
        _storageService = storageService ?? SecureStorageService();

  UserModel? get currentUser => _cachedUser;

  /// Register a new user account and securely persist tokens.
  Future<UserModel> register({
    required String email,
    required String username,
    required String password,
    String country = 'Global',
    String phoneNumber = '',
  }) async {
    final response = await _apiService.register(
      email: email,
      username: username,
      password: password,
      country: country,
      phoneNumber: phoneNumber,
    );

    if (response.tokens != null) {
      await _storageService.saveTokens(
        accessToken: response.tokens!.access,
        refreshToken: response.tokens!.refresh,
      );
    }

    if (response.user != null) {
      _cachedUser = response.user;
      await _storageService.saveUserId(response.user!.id);
      return response.user!;
    }

    throw Exception('Registration succeeded but user profile was not returned');
  }

  /// Authenticate an existing user and save token pair.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.login(
      email: email,
      password: password,
    );

    if (response.tokens != null) {
      await _storageService.saveTokens(
        accessToken: response.tokens!.access,
        refreshToken: response.tokens!.refresh,
      );
    }

    if (response.user != null) {
      _cachedUser = response.user;
      await _storageService.saveUserId(response.user!.id);
      return response.user!;
    }

    throw Exception('Login succeeded but user profile was not returned');
  }

  /// Restore user session from persistent storage.
  Future<UserModel?> restoreSession() async {
    final hasSession = await _storageService.hasValidSession();
    if (!hasSession) return null;

    try {
      final user = await _apiService.fetchUserProfile();
      _cachedUser = user;
      return user;
    } catch (_) {
      // If fetching fails or token is revoked, clear session
      await _storageService.clearAll();
      _cachedUser = null;
      return null;
    }
  }

  /// Invalidate tokens and clear local cache.
  Future<void> logout() async {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _apiService.logout(refreshToken: refreshToken);
    }
    await _storageService.clearAll();
    _cachedUser = null;
  }

  /// Request password reset.
  Future<void> requestPasswordReset(String email) async {
    await _apiService.requestPasswordReset(email: email);
  }
}

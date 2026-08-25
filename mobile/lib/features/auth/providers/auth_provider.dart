import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

/// Provider for accessing the AuthRepository singleton.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// StateNotifierProvider managing authentication lifecycle and sessions.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState.initial()) {
    restoreSession();
  }

  /// Check stored session on startup.
  Future<void> restoreSession() async {
    state = AuthState.loading();
    try {
      final user = await _repository.restoreSession();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (_) {
      state = AuthState.unauthenticated();
    }
  }

  /// Sign in with email and password.
  Future<bool> login({required String email, required String password}) async {
    state = AuthState.loading();
    try {
      final user = await _repository.login(email: email, password: password);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Register a new account.
  Future<bool> register({
    required String email,
    required String username,
    required String password,
    String country = 'Global',
    String phoneNumber = '',
  }) async {
    state = AuthState.loading();
    try {
      final user = await _repository.register(
        email: email,
        username: username,
        password: password,
        country: country,
        phoneNumber: phoneNumber,
      );
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Log out and invalidate local/remote session.
  Future<void> logout() async {
    state = AuthState.loading();
    try {
      await _repository.logout();
    } finally {
      state = AuthState.unauthenticated();
    }
  }

  /// Clear any active error message.
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(errorMessage: null, status: AuthStatus.unauthenticated);
    }
  }
}

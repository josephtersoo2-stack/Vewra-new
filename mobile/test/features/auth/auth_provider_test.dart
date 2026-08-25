import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/models/user_model.dart';
import 'package:vewra_mobile/features/auth/providers/auth_provider.dart';
import 'package:vewra_mobile/features/auth/providers/auth_state.dart';
import 'package:vewra_mobile/features/auth/data/auth_repository.dart';

class MockAuthRepository extends AuthRepository {
  bool shouldSucceed = true;
  UserModel? mockUser;

  @override
  Future<UserModel> login({required String email, required String password}) async {
    if (!shouldSucceed) throw Exception('Invalid credentials');
    return mockUser ??
        UserModel(
          id: 'test_id',
          username: 'test_user',
          email: email,
        );
  }

  @override
  Future<UserModel> register({
    required String email,
    required String username,
    required String password,
    String country = 'Global',
    String phoneNumber = '',
  }) async {
    if (!shouldSucceed) throw Exception('Registration failed');
    return UserModel(
      id: 'reg_id',
      username: username,
      email: email,
    );
  }

  @override
  Future<UserModel?> restoreSession() async {
    return shouldSucceed ? mockUser : null;
  }

  @override
  Future<void> logout() async {
    mockUser = null;
  }
}

void main() {
  group('AuthNotifier Provider Tests', () {
    late MockAuthRepository mockRepository;
    late AuthNotifier notifier;

    setUp(() {
      mockRepository = MockAuthRepository();
      notifier = AuthNotifier(mockRepository);
    });

    test('initial state handles session restore', () async {
      mockRepository.mockUser = const UserModel(
        id: 'usr_1',
        username: 'saved_user',
        email: 'saved@vewra.io',
      );
      await notifier.restoreSession();
      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.username, 'saved_user');
    });

    test('login success transitions state to authenticated', () async {
      final success = await notifier.login(email: 'user@vewra.io', password: 'pass');
      expect(success, isTrue);
      expect(notifier.state.status, AuthStatus.authenticated);
      expect(notifier.state.user?.email, 'user@vewra.io');
    });

    test('login failure transitions state to error', () async {
      mockRepository.shouldSucceed = false;
      final success = await notifier.login(email: 'wrong@vewra.io', password: 'bad');
      expect(success, isFalse);
      expect(notifier.state.status, AuthStatus.error);
      expect(notifier.state.errorMessage, contains('Invalid credentials'));
    });

    test('logout transitions state to unauthenticated', () async {
      await notifier.login(email: 'user@vewra.io', password: 'pass');
      expect(notifier.state.isAuthenticated, isTrue);

      await notifier.logout();
      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.user, isNull);
    });
  });
}

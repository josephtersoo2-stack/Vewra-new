import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/models/user_model.dart';
import 'package:vewra_mobile/features/profile/models/preference_model.dart';
import 'package:vewra_mobile/features/profile/models/statistics_model.dart';
import 'package:vewra_mobile/features/profile/models/subscription_model.dart';
import 'package:vewra_mobile/features/profile/models/verification_status_model.dart';
import 'package:vewra_mobile/features/profile/data/profile_repository.dart';
import 'package:vewra_mobile/features/profile/data/profile_api_service.dart';

class FakeProfileApiService extends ProfileApiService {
  bool shouldSucceed = true;

  @override
  Future<UserModel> fetchProfile() async {
    if (!shouldSucceed) throw Exception('Fetch profile failed');
    return const UserModel(
      id: 'usr_test_1',
      username: 'alex_developer',
      email: 'alex.dev@vewra.io',
      displayName: 'Alex Prime',
      bio: 'Ecosystem Explorer',
      country: 'Canada',
      city: 'Vancouver',
    );
  }

  @override
  Future<UserModel> updateProfile({
    String? displayName,
    String? bio,
    String? country,
    String? city,
    String? language,
    String? currency,
    String? timezone,
    String? gender,
    String? dateOfBirth,
  }) async {
    if (!shouldSucceed) throw Exception('Update profile failed');
    return UserModel(
      id: 'usr_test_1',
      username: 'alex_developer',
      email: 'alex.dev@vewra.io',
      displayName: displayName ?? 'Alex Prime',
      bio: bio ?? 'Ecosystem Explorer',
      country: country ?? 'Canada',
      city: city ?? 'Vancouver',
    );
  }

  @override
  Future<UserStatisticsModel> fetchStatistics() async {
    return const UserStatisticsModel(tasksCompleted: 42, videosWatched: 120);
  }

  @override
  Future<UserPreferenceModel> fetchPreferences() async {
    return const UserPreferenceModel(theme: 'dark', pushNotifications: true);
  }

  @override
  Future<VerificationStatusModel> fetchVerificationStatus() async {
    return const VerificationStatusModel(id: 1, verificationLevel: 'BASIC', status: 'NOT_STARTED');
  }

  @override
  Future<VerificationStatusModel> submitVerification({
    required String country,
    required String documentType,
    required String documentReference,
  }) async {
    return VerificationStatusModel(
      id: 1,
      country: country,
      documentType: documentType,
      documentReference: documentReference,
      status: 'PENDING',
    );
  }

  @override
  Future<List<SubscriptionTierModel>> fetchSubscriptionPlans() async {
    return const [
      SubscriptionTierModel(
        id: 1,
        name: 'FREE',
        slug: 'free',
        description: 'Standard plan',
        monthlyPrice: 0.0,
        annualPrice: 0.0,
        benefits: ['1x rate'],
      ),
      SubscriptionTierModel(
        id: 2,
        name: 'PREMIUM',
        slug: 'premium',
        description: 'Premium plan',
        monthlyPrice: 4.99,
        annualPrice: 49.99,
        benefits: ['2x rate'],
      ),
    ];
  }

  @override
  Future<UserSubscriptionModel> fetchMySubscription() async {
    return const UserSubscriptionModel(
      id: 1,
      tier: SubscriptionTierModel(
        id: 2,
        name: 'PREMIUM',
        slug: 'premium',
        description: 'Premium plan',
        monthlyPrice: 4.99,
        annualPrice: 49.99,
        benefits: ['2x rate'],
      ),
    );
  }
}

void main() {
  group('ProfileRepository Unit Tests', () {
    late FakeProfileApiService fakeApi;
    late ProfileRepository repository;

    setUp(() {
      fakeApi = FakeProfileApiService();
      repository = ProfileRepository(apiService: fakeApi);
    });

    test('fetchProfile caches and returns user model', () async {
      final profile = await repository.fetchProfile();
      expect(profile.displayName, 'Alex Prime');
      expect(repository.currentProfile, isNotNull);
    });

    test('updateProfile updates cache and returns updated user', () async {
      final updated = await repository.updateProfile(displayName: 'Alex Supreme');
      expect(updated.displayName, 'Alex Supreme');
      expect(repository.currentProfile?.displayName, 'Alex Supreme');
    });

    test('submitVerification updates status to PENDING', () async {
      final verification = await repository.submitVerification(
        country: 'Canada',
        documentType: 'PASSPORT',
        documentReference: 'CAN-12345',
      );
      expect(verification.isPending, isTrue);
      expect(verification.documentReference, 'CAN-12345');
    });

    test('fetchSubscriptionPlans returns tiers list', () async {
      final plans = await repository.fetchSubscriptionPlans();
      expect(plans.length, 2);
      expect(plans.first.name, 'FREE');
    });
  });
}

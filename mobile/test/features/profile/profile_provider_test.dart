import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/models/user_model.dart';
import 'package:vewra_mobile/features/profile/models/verification_status_model.dart';
import 'package:vewra_mobile/features/profile/models/subscription_model.dart';
import 'package:vewra_mobile/features/profile/data/profile_repository.dart';
import 'package:vewra_mobile/features/profile/providers/profile_provider.dart';

class MockProfileRepository extends ProfileRepository {
  bool shouldSucceed = true;

  @override
  Future<UserModel> fetchProfile() async {
    if (!shouldSucceed) throw Exception('Network error');
    return const UserModel(
      id: 'usr_mock',
      username: 'test_user',
      email: 'test@vewra.io',
      displayName: 'Test User',
      level: 10,
      trustScore: 90,
    );
  }

  @override
  Future<VerificationStatusModel> fetchVerificationStatus() async {
    return const VerificationStatusModel(id: 1, verificationLevel: 'VERIFIED', status: 'APPROVED');
  }

  @override
  Future<UserSubscriptionModel> fetchMySubscription() async {
    return const UserSubscriptionModel(
      id: 1,
      tier: SubscriptionTierModel(
        id: 1,
        name: 'FREE',
        slug: 'free',
        description: 'Standard plan',
        monthlyPrice: 0.0,
        annualPrice: 0.0,
        benefits: [],
      ),
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
        benefits: [],
      ),
    ];
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
    return UserModel(
      id: 'usr_mock',
      username: 'test_user',
      email: 'test@vewra.io',
      displayName: displayName ?? 'Test User',
    );
  }

  @override
  Future<VerificationStatusModel> submitVerification({
    required String country,
    required String documentType,
    required String documentReference,
  }) async {
    return const VerificationStatusModel(
      id: 1,
      status: 'PENDING',
      verificationLevel: 'BASIC',
    );
  }
}

void main() {
  group('ProfileNotifier Provider Tests', () {
    late MockProfileRepository mockRepository;
    late ProfileNotifier notifier;

    setUp(() {
      mockRepository = MockProfileRepository();
      notifier = ProfileNotifier(mockRepository);
    });

    test('loadFullProfile loads user and ecosystem records', () async {
      await notifier.loadFullProfile();
      expect(notifier.state.user, isNotNull);
      expect(notifier.state.user?.displayName, 'Test User');
      expect(notifier.state.verification?.isApproved, isTrue);
    });

    test('updateProfile updates user state', () async {
      await notifier.loadFullProfile();
      final success = await notifier.updateProfile(displayName: 'Updated Name');
      expect(success, isTrue);
      expect(notifier.state.user?.displayName, 'Updated Name');
    });

    test('submitVerification updates verification state to PENDING', () async {
      await notifier.loadFullProfile();
      final success = await notifier.submitVerification(
        country: 'Global',
        documentType: 'NATIONAL_ID',
        documentReference: '12345678',
      );
      expect(success, isTrue);
      expect(notifier.state.verification?.isPending, isTrue);
    });
  });
}

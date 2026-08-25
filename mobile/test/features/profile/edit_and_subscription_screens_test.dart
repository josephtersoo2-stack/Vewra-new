import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/models/user_model.dart';
import 'package:vewra_mobile/features/profile/models/subscription_model.dart';
import 'package:vewra_mobile/features/profile/models/verification_status_model.dart';
import 'package:vewra_mobile/features/profile/data/profile_repository.dart';
import 'package:vewra_mobile/features/profile/providers/profile_provider.dart';
import 'package:vewra_mobile/features/profile/screens/edit_profile_screen.dart';
import 'package:vewra_mobile/features/profile/screens/subscription_screen.dart';

class MockProfileRepoForScreens extends ProfileRepository {
  @override
  Future<UserModel> fetchProfile() async {
    return const UserModel(
      id: 'usr_screen_test',
      username: 'alex_developer',
      email: 'alex.dev@vewra.io',
      displayName: 'Alex Developer',
      level: 14,
      xp: 2450,
      xpNextLevel: 3000,
      trustScore: 96,
      verificationStatus: 'Verified',
      subscriptionTier: 'Premium',
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
    return UserModel(
      id: 'usr_screen_test',
      username: 'alex_developer',
      email: 'alex.dev@vewra.io',
      displayName: displayName ?? 'Alex Developer',
      bio: bio ?? '',
      country: country ?? 'Canada',
      city: city ?? 'Toronto',
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
      SubscriptionTierModel(
        id: 3,
        name: 'PRO',
        slug: 'pro',
        description: 'Pro plan',
        monthlyPrice: 14.99,
        annualPrice: 149.99,
        benefits: ['3x rate'],
      ),
    ];
  }
}

void main() {
  group('Phase 3 Profile & Subscription Screens Tests', () {
    testWidgets('EditProfileScreen renders fields and updates profile', (WidgetTester tester) async {
      final mockRepo = MockProfileRepoForScreens();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byKey(const Key('edit_display_name_field')), findsOneWidget);
      expect(find.byKey(const Key('edit_bio_field')), findsOneWidget);
      expect(find.byKey(const Key('edit_country_field')), findsOneWidget);
      expect(find.byKey(const Key('edit_city_field')), findsOneWidget);
      expect(find.byKey(const Key('save_profile_button')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('edit_display_name_field')), 'Alex Master Pro');
      await tester.enterText(find.byKey(const Key('edit_city_field')), 'Toronto');
      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('SubscriptionScreen renders active tier and available plans', (WidgetTester tester) async {
      final mockRepo = MockProfileRepoForScreens();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: SubscriptionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Membership & Plans'), findsOneWidget);
      expect(find.text('Active Membership'), findsOneWidget);
      expect(find.text('Available Plans'), findsOneWidget);
      expect(find.text('FREE'), findsWidgets);
      expect(find.text('PREMIUM'), findsWidgets);
      expect(find.text('PRO'), findsWidgets);
    });
  });
}

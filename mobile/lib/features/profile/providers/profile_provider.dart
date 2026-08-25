import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../../services/dummy_data_service.dart';
import '../data/profile_repository.dart';
import '../models/subscription_model.dart';
import '../models/verification_status_model.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileState {
  final ProfileStatus status;
  final UserModel? user;
  final VerificationStatusModel? verification;
  final UserSubscriptionModel? subscription;
  final List<SubscriptionTierModel> plans;
  final String? errorMessage;

  const ProfileState({
    required this.status,
    this.user,
    this.verification,
    this.subscription,
    this.plans = const [],
    this.errorMessage,
  });

  factory ProfileState.initial() => const ProfileState(status: ProfileStatus.initial);
  factory ProfileState.loading({UserModel? user}) =>
      ProfileState(status: ProfileStatus.loading, user: user);
  factory ProfileState.error(String message, {UserModel? user}) =>
      ProfileState(status: ProfileStatus.error, errorMessage: message, user: user);

  bool get isLoading => status == ProfileStatus.loading;
  bool get hasError => status == ProfileStatus.error;

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    VerificationStatusModel? verification,
    UserSubscriptionModel? subscription,
    List<SubscriptionTierModel>? plans,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      verification: verification ?? this.verification,
      subscription: subscription ?? this.subscription,
      plans: plans ?? this.plans,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository)
      : super(
          ProfileState(
            status: ProfileStatus.success,
            user: _repository.currentProfile ?? DummyDataService.currentUser,
            verification: const VerificationStatusModel(
              id: 1,
              verificationLevel: 'VERIFIED',
              status: 'APPROVED',
            ),
            subscription: const UserSubscriptionModel(
              id: 1,
              tier: SubscriptionTierModel(
                id: 2,
                name: 'PREMIUM',
                slug: 'premium',
                description: 'Enhanced earning rate and exclusive benefits',
                monthlyPrice: 4.99,
                annualPrice: 49.99,
                benefits: ['2x Watch reward multiplier', 'Priority KYC queue', '3 daily spins'],
              ),
            ),
          ),
        );

  /// Load profile, verification status, and subscriptions from remote API.
  Future<void> loadFullProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final results = await Future.wait([
        _repository.fetchProfile(),
        _repository.fetchVerificationStatus().catchError((_) => const VerificationStatusModel(id: 0)),
        _repository.fetchMySubscription().catchError(
              (_) => const UserSubscriptionModel(
                id: 0,
                tier: SubscriptionTierModel(
                  id: 0,
                  name: 'FREE',
                  slug: 'free',
                  description: 'Standard plan',
                  monthlyPrice: 0.0,
                  annualPrice: 0.0,
                  benefits: [],
                ),
              ),
            ),
        _repository.fetchSubscriptionPlans().catchError((_) => <SubscriptionTierModel>[]),
      ]);

      final user = results[0] as UserModel;
      final verification = results[1] as VerificationStatusModel;
      final subscription = results[2] as UserSubscriptionModel;
      final plans = results[3] as List<SubscriptionTierModel>;

      state = ProfileState(
        status: ProfileStatus.success,
        user: user,
        verification: verification,
        subscription: subscription,
        plans: plans,
      );
    } catch (e) {
      final fallbackUser = _repository.currentProfile ?? DummyDataService.currentUser;
      state = ProfileState(
        status: ProfileStatus.success,
        user: fallbackUser,
        verification: const VerificationStatusModel(id: 1, verificationLevel: 'VERIFIED', status: 'APPROVED'),
        subscription: const UserSubscriptionModel(
          id: 1,
          tier: SubscriptionTierModel(
            id: 2,
            name: 'PREMIUM',
            slug: 'premium',
            description: 'Enhanced earning rate and exclusive benefits',
            monthlyPrice: 4.99,
            annualPrice: 49.99,
            benefits: ['2x Watch reward multiplier', 'Priority KYC queue', '3 daily spins'],
          ),
        ),
      );
    }
  }

  /// Update profile info.
  Future<bool> updateProfile({
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
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final updated = await _repository.updateProfile(
        displayName: displayName,
        bio: bio,
        country: country,
        city: city,
        language: language,
        currency: currency,
        timezone: timezone,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      state = state.copyWith(status: ProfileStatus.success, user: updated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Submit KYC verification documents.
  Future<bool> submitVerification({
    required String country,
    required String documentType,
    required String documentReference,
  }) async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final verification = await _repository.submitVerification(
        country: country,
        documentType: documentType,
        documentReference: documentReference,
      );
      final updatedUser = state.user?.copyWith(verificationStatus: 'Pending Review');
      state = state.copyWith(
        status: ProfileStatus.success,
        verification: verification,
        user: updatedUser,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

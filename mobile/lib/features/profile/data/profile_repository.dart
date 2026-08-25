import '../../../models/user_model.dart';
import '../models/preference_model.dart';
import '../models/statistics_model.dart';
import '../models/subscription_model.dart';
import '../models/verification_status_model.dart';
import 'profile_api_service.dart';

/// Repository managing user profile, preferences, verification, and subscriptions.
class ProfileRepository {
  final ProfileApiService _apiService;

  UserModel? _cachedProfile;
  UserPreferenceModel? _cachedPreferences;
  UserStatisticsModel? _cachedStatistics;
  VerificationStatusModel? _cachedVerification;
  List<SubscriptionTierModel>? _cachedPlans;
  UserSubscriptionModel? _cachedSubscription;

  ProfileRepository({ProfileApiService? apiService})
      : _apiService = apiService ?? ProfileApiService();

  UserModel? get currentProfile => _cachedProfile;
  UserPreferenceModel? get currentPreferences => _cachedPreferences;
  UserStatisticsModel? get currentStatistics => _cachedStatistics;
  VerificationStatusModel? get currentVerification => _cachedVerification;
  List<SubscriptionTierModel>? get cachedPlans => _cachedPlans;
  UserSubscriptionModel? get currentSubscription => _cachedSubscription;

  /// Fetch full user profile and cache locally.
  Future<UserModel> fetchProfile() async {
    final profile = await _apiService.fetchProfile();
    _cachedProfile = profile;
    _cachedPreferences = profile.preferences;
    _cachedStatistics = profile.statistics;
    return profile;
  }

  /// Update user profile details.
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
    final updated = await _apiService.updateProfile(
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
    _cachedProfile = updated;
    return updated;
  }

  /// Fetch user statistics.
  Future<UserStatisticsModel> fetchStatistics() async {
    final stats = await _apiService.fetchStatistics();
    _cachedStatistics = stats;
    return stats;
  }

  /// Fetch user preferences.
  Future<UserPreferenceModel> fetchPreferences() async {
    final prefs = await _apiService.fetchPreferences();
    _cachedPreferences = prefs;
    return prefs;
  }

  /// Update preferences.
  Future<UserPreferenceModel> updatePreferences({
    String? theme,
    String? language,
    bool? notificationEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
  }) async {
    final prefs = await _apiService.updatePreferences(
      theme: theme,
      language: language,
      notificationEnabled: notificationEnabled,
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
    );
    _cachedPreferences = prefs;
    return prefs;
  }

  /// Fetch verification status.
  Future<VerificationStatusModel> fetchVerificationStatus() async {
    final verification = await _apiService.fetchVerificationStatus();
    _cachedVerification = verification;
    return verification;
  }

  /// Submit verification documentation.
  Future<VerificationStatusModel> submitVerification({
    required String country,
    required String documentType,
    required String documentReference,
  }) async {
    final verification = await _apiService.submitVerification(
      country: country,
      documentType: documentType,
      documentReference: documentReference,
    );
    _cachedVerification = verification;
    if (_cachedProfile != null) {
      _cachedProfile = _cachedProfile!.copyWith(verificationStatus: 'Pending Review');
    }
    return verification;
  }

  /// Fetch subscription plans list.
  Future<List<SubscriptionTierModel>> fetchSubscriptionPlans() async {
    final plans = await _apiService.fetchSubscriptionPlans();
    _cachedPlans = plans;
    return plans;
  }

  /// Fetch user subscription detail.
  Future<UserSubscriptionModel> fetchMySubscription() async {
    final sub = await _apiService.fetchMySubscription();
    _cachedSubscription = sub;
    return sub;
  }
}

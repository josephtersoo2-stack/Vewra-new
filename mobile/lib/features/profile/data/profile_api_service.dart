import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../models/user_model.dart';
import '../models/preference_model.dart';
import '../models/statistics_model.dart';
import '../models/subscription_model.dart';
import '../models/verification_status_model.dart';

/// API Service for all Phase 3 user profile, verification, preferences, and subscription endpoints.
class ProfileApiService {
  final ApiClient _apiClient;

  ProfileApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch full user profile.
  Future<UserModel> fetchProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.userProfile);
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['user'] is Map<String, dynamic>) {
          return UserModel.fromJson(data['user'] as Map<String, dynamic>);
        }
      }
      throw const FormatException('Invalid user profile structure');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch user profile');
    }
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
    try {
      final payload = <String, dynamic>{};
      if (displayName != null) payload['display_name'] = displayName;
      if (bio != null) payload['bio'] = bio;
      if (country != null) payload['country'] = country;
      if (city != null) payload['city'] = city;
      if (language != null) payload['language'] = language;
      if (currency != null) payload['currency'] = currency;
      if (timezone != null) payload['timezone'] = timezone;
      if (gender != null) payload['gender'] = gender;
      if (dateOfBirth != null) payload['date_of_birth'] = dateOfBirth;

      final response = await _apiClient.patch(
        ApiConstants.userProfileUpdate,
        data: payload,
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['user'] is Map<String, dynamic>) {
          return UserModel.fromJson(data['user'] as Map<String, dynamic>);
        }
      }
      throw const FormatException('Invalid user update response');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to update user profile');
    }
  }

  /// Upload user profile avatar image.
  Future<UserModel> uploadAvatar(String filePath) async {
    try {
      final fileName = filePath.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiClient.patch(
        ApiConstants.userProfileUpdate,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['user'] is Map<String, dynamic>) {
          return UserModel.fromJson(data['user'] as Map<String, dynamic>);
        }
      }
      throw const FormatException('Invalid avatar upload response');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to upload profile avatar');
    }
  }

  /// Fetch user statistics.
  Future<UserStatisticsModel> fetchStatistics() async {
    try {
      final response = await _apiClient.get(ApiConstants.userStatistics);
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['statistics'] is Map<String, dynamic>) {
          return UserStatisticsModel.fromJson(data['statistics'] as Map<String, dynamic>);
        }
      }
      throw const FormatException('Invalid statistics structure');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch statistics');
    }
  }

  /// Fetch user preferences.
  Future<UserPreferenceModel> fetchPreferences() async {
    try {
      final response = await _apiClient.get(ApiConstants.userPreferences);
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['preferences'] is Map<String, dynamic>) {
          return UserPreferenceModel.fromJson(data['preferences'] as Map<String, dynamic>);
        }
      }
      throw const FormatException('Invalid preferences structure');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch preferences');
    }
  }

  /// Update user preferences.
  Future<UserPreferenceModel> updatePreferences({
    String? theme,
    String? language,
    bool? notificationEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (theme != null) payload['theme'] = theme;
      if (language != null) payload['language'] = language;
      if (notificationEnabled != null) payload['notification_enabled'] = notificationEnabled;
      if (emailNotifications != null) payload['email_notifications'] = emailNotifications;
      if (pushNotifications != null) payload['push_notifications'] = pushNotifications;

      final response = await _apiClient.patch(
        ApiConstants.userPreferencesUpdate,
        data: payload,
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['preferences'] is Map<String, dynamic>) {
          return UserPreferenceModel.fromJson(data['preferences'] as Map<String, dynamic>);
        }
      }
      throw const FormatException('Invalid preferences update response');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to update preferences');
    }
  }

  /// Fetch verification status.
  Future<VerificationStatusModel> fetchVerificationStatus() async {
    try {
      final response = await _apiClient.get(ApiConstants.verificationStatus);
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['verification'] is Map<String, dynamic>) {
          return VerificationStatusModel.fromJson(data['verification'] as Map<String, dynamic>);
        }
      }
      throw const FormatException('Invalid verification structure');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch verification status');
    }
  }

  /// Submit verification documentation.
  Future<VerificationStatusModel> submitVerification({
    required String country,
    required String documentType,
    required String documentReference,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verificationSubmit,
        data: {
          'country': country,
          'document_type': documentType,
          'document_reference': documentReference,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['verification'] is Map<String, dynamic>) {
          return VerificationStatusModel.fromJson(data['verification'] as Map<String, dynamic>);
        }
      }
      throw const FormatException('Invalid verification submit response');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to submit verification');
    }
  }

  /// Fetch subscription plans.
  Future<List<SubscriptionTierModel>> fetchSubscriptionPlans() async {
    try {
      final response = await _apiClient.get(ApiConstants.subscriptionPlans);
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['plans'] is List) {
          return (data['plans'] as List)
              .map((p) => SubscriptionTierModel.fromJson(p as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch subscription plans');
    }
  }

  /// Fetch user subscription detail.
  Future<UserSubscriptionModel> fetchMySubscription() async {
    try {
      final response = await _apiClient.get(ApiConstants.mySubscription);
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['subscription'] is Map<String, dynamic>) {
          return UserSubscriptionModel.fromJson(data['subscription'] as Map<String, dynamic>);
        }
      }
      throw const FormatException('Invalid subscription response structure');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch user subscription');
    }
  }
}

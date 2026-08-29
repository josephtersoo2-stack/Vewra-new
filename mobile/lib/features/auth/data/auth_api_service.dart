import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../models/user_model.dart';
import '../models/auth_response_model.dart';

/// Service making network HTTP calls to authentication endpoints.
class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Register a new user account.
  Future<AuthResponseModel> register({
    required String email,
    required String username,
    required String password,
    String country = 'Global',
    String phoneNumber = '',
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'username': username,
          'password': password,
          'country': country,
          'phone_number': phoneNumber,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const FormatException('Unexpected response format from register API');
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String errorMsg = 'Registration failed. Please check your details.';
      if (errorData is Map<String, dynamic>) {
        if (errorData['errors'] is Map) {
          final errMap = errorData['errors'] as Map;
          final firstKey = errMap.keys.firstOrNull;
          if (firstKey != null && errMap[firstKey] is List) {
            errorMsg = '$firstKey: ${errMap[firstKey][0]}';
          }
        } else if (errorData['message'] != null) {
          errorMsg = errorData['message'].toString();
        }
      }
      throw Exception(errorMsg);
    }
  }

  /// Authenticate an existing user with email and password.
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const FormatException('Unexpected response format from login API');
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String errorMsg;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Connection timed out. Please check your network.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'Unable to connect to backend server. Please verify backend service.';
      } else {
        errorMsg = 'Invalid email or password.';
      }

      if (errorData is Map<String, dynamic>) {
        if (errorData['errors'] is Map) {
          final errMap = errorData['errors'] as Map;
          final firstKey = errMap.keys.firstOrNull;
          if (firstKey != null && errMap[firstKey] is List) {
            errorMsg = '${errMap[firstKey][0]}';
          }
        } else if (errorData['message'] != null) {
          errorMsg = errorData['message'].toString();
        }
      }
      throw Exception(errorMsg);
    }
  }

  /// Invalidate refresh token upon logout.
  Future<void> logout({required String refreshToken}) async {
    try {
      await _apiClient.post(
        ApiConstants.logout,
        data: {'refresh': refreshToken},
      );
    } catch (_) {
      // Ignored for network errors during logout
    }
  }

  /// Fetch currently authenticated user profile data.
  Future<UserModel> fetchUserProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.userProfile);
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['user'] is Map<String, dynamic>) {
          return UserModel.fromJson(data['user'] as Map<String, dynamic>);
        }
      }
      throw const FormatException('Invalid profile payload structure');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch user profile');
    }
  }

  /// Request password reset link/token.
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _apiClient.post(
        ApiConstants.passwordReset,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to request password reset');
    }
  }
}

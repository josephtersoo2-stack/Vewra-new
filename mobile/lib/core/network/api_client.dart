import 'package:dio/dio.dart';
import 'api_constants.dart';
import '../storage/secure_storage_service.dart';

/// Centralized Dio HTTP client wrapper with automatic JWT token injection and error handling.
class ApiClient {
  final Dio _dio;
  final SecureStorageService _storageService;

  ApiClient({
    Dio? dio,
    SecureStorageService? storageService,
    String? baseUrl,
  })  : _storageService = storageService ?? SecureStorageService(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? ApiConstants.defaultBaseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                sendTimeout: ApiConstants.sendTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Exclude auth endpoints from Authorization header
          final isAuthEndpoint = options.path.contains('/auth/login') ||
              options.path.contains('/auth/register') ||
              options.path.contains('/auth/password-reset');

          if (!isAuthEndpoint) {
            final token = await _storageService.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Handle 401 Unauthorized token refresh
          if (error.response?.statusCode == 401 && !error.requestOptions.path.contains('/auth/')) {
            final refreshed = await _attemptTokenRefresh();
            if (refreshed) {
              final newAccessToken = await _storageService.getAccessToken();
              final retryOptions = error.requestOptions;
              retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              try {
                final response = await _dio.fetch(retryOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            } else {
              await _storageService.clearAll();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _attemptTokenRefresh() async {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccess = response.data['access'] as String?;
        if (newAccess != null) {
          await _storageService.saveAccessToken(newAccess);
          final newRefresh = response.data['refresh'] as String?;
          if (newRefresh != null) {
            await _storageService.saveRefreshToken(newRefresh);
          }
          return true;
        }
      }
    } catch (_) {
      // Refresh failed
    }
    return false;
  }

  // Generic HTTP Methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }
}

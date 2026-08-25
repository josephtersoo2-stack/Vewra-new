import '../../../models/user_model.dart';

/// Model representing JWT token pair.
class AuthTokensModel {
  final String access;
  final String refresh;
  final String tokenType;

  const AuthTokensModel({
    required this.access,
    required this.refresh,
    this.tokenType = 'Bearer',
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      access: json['access']?.toString() ?? '',
      refresh: json['refresh']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
      'token_type': tokenType,
    };
  }
}

/// Model representing authentication API response payload.
class AuthResponseModel {
  final String status;
  final String message;
  final AuthTokensModel? tokens;
  final UserModel? user;

  const AuthResponseModel({
    required this.status,
    required this.message,
    this.tokens,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      status: json['status']?.toString() ?? 'success',
      message: json['message']?.toString() ?? '',
      tokens: json['tokens'] != null
          ? AuthTokensModel.fromJson(json['tokens'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

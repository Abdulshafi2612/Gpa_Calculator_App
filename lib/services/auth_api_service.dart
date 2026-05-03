import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/user/user_response.dart';

class AuthApiService {
  final Dio _dio = ApiClient().dio;

  /// Register a new user. Returns [UserResponse] on success.
  Future<UserResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );
      return UserResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Login and receive access + refresh tokens.
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Register then auto-login in one call. Returns [AuthResponse] with tokens.
  Future<AuthResponse> registerAndLogin(RegisterRequest request) async {
    await register(request);
    return login(LoginRequest(email: request.email, password: request.password));
  }
}

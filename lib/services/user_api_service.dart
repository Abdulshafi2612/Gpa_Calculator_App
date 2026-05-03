import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user/user_response.dart';

class UserApiService {
  final Dio _dio = ApiClient().dio;

  /// Fetch the currently authenticated user's profile.
  Future<UserResponse> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConstants.currentUser);
      return UserResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }
}

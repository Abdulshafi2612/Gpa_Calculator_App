import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/gpa/cgpa_response.dart';

class GpaApiService {
  final Dio _dio = ApiClient().dio;

  /// Fetch CGPA, total credits, and semester count for the current user.
  Future<CgpaResponse> getCgpa() async {
    try {
      final response = await _dio.get(ApiConstants.cgpa);
      return CgpaResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }
}

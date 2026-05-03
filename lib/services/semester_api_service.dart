import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/semester/all_semesters_response.dart';
import '../models/semester/semester_request.dart';
import '../models/semester/semester_response.dart';

class SemesterApiService {
  final Dio _dio = ApiClient().dio;

  /// Create a new semester with subjects.
  Future<SemesterResponse> createSemester(SemesterRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.semesters,
        data: request.toJson(),
      );
      return SemesterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Get all semesters as lightweight summaries (no subjects).
  Future<List<AllSemestersResponse>> getAllSemesters() async {
    try {
      final response = await _dio.get(ApiConstants.semesters);
      return (response.data as List)
          .map((s) => AllSemestersResponse.fromJson(s))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Get a single semester by ID, including full subject details.
  Future<SemesterResponse> getSemesterById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.semesterById(id));
      return SemesterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Update a semester (replaces subjects).
  Future<SemesterResponse> updateSemester(
      int id, SemesterRequest request) async {
    try {
      final response = await _dio.put(
        ApiConstants.semesterById(id),
        data: request.toJson(),
      );
      return SemesterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Delete a semester and its subjects.
  Future<void> deleteSemester(int id) async {
    try {
      await _dio.delete(ApiConstants.semesterById(id));
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Toggle a semester's active status (activate/deactivate).
  Future<SemesterResponse> toggleSemesterActive(int id) async {
    try {
      final response = await _dio.patch(
        ApiConstants.toggleSemesterActive(id),
      );
      return SemesterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }
}

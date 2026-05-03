import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_exceptions.dart';

/// Global navigator key used to redirect to login on auth failure.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Singleton Dio wrapper with:
/// - Automatic `Authorization` header injection
/// - Proactive token refresh (~2 min before expiry)
/// - 401 fallback refresh + retry
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final TokenStorage _tokenStorage = TokenStorage();
  bool _isRefreshing = false;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  // ── Public Helpers ─────────────────────────────────────

  TokenStorage get tokenStorage => _tokenStorage;

  /// Create a bare Dio that skips auth interceptors (used for refresh call).
  Dio get _plainDio => Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  // ── Request Interceptor ────────────────────────────────

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints.
    final publicPaths = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.refresh,
    ];
    if (publicPaths.contains(options.path)) {
      return handler.next(options);
    }

    // Proactive refresh if token is about to expire.
    if (!_isRefreshing && await _tokenStorage.isTokenExpiringSoon()) {
      await _tryProactiveRefresh();
    }

    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  // ── Error Interceptor (401 fallback) ───────────────────

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final publicPaths = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.refresh,
    ];
    
    // Do not intercept 401 for public endpoints (like login/register)
    // because returning 401 here just means bad credentials, not a session timeout.
    final isPublicEndpoint = publicPaths.contains(err.requestOptions.path);

    if (err.response?.statusCode == 401 && !_isRefreshing && !isPublicEndpoint) {
      final retried = await _handle401(err);
      if (retried != null) {
        return handler.resolve(retried);
      }
    }
    return handler.next(err);
  }

  // ── Token Refresh Logic ────────────────────────────────

  Future<void> _tryProactiveRefresh() async {
    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return;

      final response = await _plainDio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await _tokenStorage.saveTokens(
          accessToken: response.data['accessToken'],
          refreshToken: response.data['refreshToken'],
        );
      }
    } catch (_) {
      // Proactive refresh failed — will rely on 401 fallback.
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response?> _handle401(DioException err) async {
    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        _redirectToLogin();
        return null;
      }

      final response = await _plainDio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccess = response.data['accessToken'] as String;
        final newRefresh = response.data['refreshToken'] as String;

        await _tokenStorage.saveTokens(
          accessToken: newAccess,
          refreshToken: newRefresh,
        );

        // Retry the original request with the new token.
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccess';
        return await _plainDio.fetch(opts);
      } else {
        _redirectToLogin();
        return null;
      }
    } catch (_) {
      _redirectToLogin();
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  void _redirectToLogin() {
    _tokenStorage.clearTokens();
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }

  // ── Static Error Mapper ────────────────────────────────

  /// Converts a [DioException] into a typed [ApiException].
  static ApiException mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }

    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? serverMsg;
    if (data is Map<String, dynamic>) {
      serverMsg = data['message'] as String?;
    }

    switch (status) {
      case 400:
        return BadRequestException(serverMsg ?? 'Invalid request. Please check your input.');
      case 401:
        return UnauthorizedException(serverMsg ?? 'Invalid email or password.');
      case 404:
        return NotFoundException(serverMsg ?? 'Resource not found.');
      case 409:
        return ConflictException(serverMsg ?? 'Conflict occurred.');
      case 500:
        return ServerException();
      default:
        return ApiException(serverMsg ?? 'An unexpected error occurred.');
    }
  }
}

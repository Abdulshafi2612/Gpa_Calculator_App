import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for JWT token persistence.
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenExpiryKey = 'token_expiry';

  /// Save both tokens and compute an estimated expiry timestamp.
  ///
  /// [expiresInMs] defaults to 24 h (86 400 000 ms) — adjust to match
  /// your backend's `app.jwt.expiration-ms`.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    int expiresInMs = 86400000,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);

    final expiryMs =
        DateTime.now().millisecondsSinceEpoch + expiresInMs;
    await prefs.setInt(_tokenExpiryKey, expiryMs);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Returns `true` if the access token will expire within
  /// the given [buffer] (default 2 min).
  Future<bool> isTokenExpiringSoon({
    Duration buffer = const Duration(minutes: 2),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryMs = prefs.getInt(_tokenExpiryKey);
    if (expiryMs == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= (expiryMs - buffer.inMilliseconds);
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }
}

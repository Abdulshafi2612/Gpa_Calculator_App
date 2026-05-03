/// Central configuration for backend API connectivity.
///
/// Change [baseUrl] depending on your runtime platform:
/// - Android emulator:  http://10.0.2.2:8080
/// - Windows / Chrome:  http://localhost:8080
class ApiConstants {
  ApiConstants._();

  /// Backend base URL — update this based on your target platform.
  static const String baseUrl =
      'https://gpa-calculator-api-mohamed-d5e8gqcgcffcg9gj.germanywestcentral-01.azurewebsites.net';

  // ── Auth ───────────────────────────────────────────────
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String refresh = '/api/auth/refresh';

  // ── User ───────────────────────────────────────────────
  static const String currentUser = '/api/users/me';

  // ── Semesters ──────────────────────────────────────────
  static const String semesters = '/api/semesters';
  static String semesterById(int id) => '/api/semesters/$id';
  static String toggleSemesterActive(int id) =>
      '/api/semesters/$id/toggle-active';

  // ── GPA ────────────────────────────────────────────────
  static const String cgpa = '/api/cgpa';
}

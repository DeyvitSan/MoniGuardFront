// lib/core/constants/api_constants.dart

abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.100.4:3000/api/v1',
  );

  // ── Endpoints ──────────────────────────────────────────────────────────────
  static const String login    = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String profileMe = '$baseUrl/auth/profile/me';
  static const String profileNameUpdate = '$baseUrl/auth/profile/name';
  static const String profilePasswordUpdate = '$baseUrl/auth/profile/password';
  static const String openMeteoBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String bitacoras = '$baseUrl/bitacoras';
  static const String parcelas = '$baseUrl/parcelas';
  static const String parcelasTiene = '$baseUrl/parcelas/tiene';
  //Dash
  static const String dashboardSummary = '$baseUrl/dashboard/summary';


  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
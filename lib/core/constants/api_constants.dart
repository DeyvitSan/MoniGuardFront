abstract final class ApiConstants {
  // El default de compilación debe ser HTTPS. Para desarrollo local contra
  // un backend en tu red LAN por HTTP, pásalo explícito en cada build/run:
  //   flutter run --dart-define=API_BASE_URL=http://TU_IP_LOCAL:3000/api/v1
  // Así nunca queda un http:// hardcodeado en el binario que se distribuye.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.moniguard.app/api/v1',
  );

  //Endpoints
  static const String login    = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String profileMe = '$baseUrl/profile/me';
  static const String profileUpdate = '$baseUrl/profile/update';
  static const String openMeteoBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String bitacoras = '$baseUrl/bitacoras';
  static const String parcelas = '$baseUrl/parcelas';
  static const String parcelasTiene = '$baseUrl/parcelas/tiene';
  //Dash
  static const String dashboardSummary = '$baseUrl/dashboard/summary';


  //Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
// La URL base se inyecta en tiempo de compilación con --dart-define-from-file.
// NUNCA hardcodear IPs de hotspot (172.20.10.x): cambian en cada reconexión
// y no existen en producción. Ver config/dev.json y config/prod.json.
//   flutter run   --dart-define-from-file=config/dev.json
//   flutter build apk --release --dart-define-from-file=config/prod.json
abstract final class ApiConstants {
  // 10.0.2.2 = alias del emulador el localhost de la maquina.
  // Es el default seguro para desarrollo; prod lo sobreescribe por dart-define.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.100.8:3000/api/v1',
  );

  //Auth
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  //Dashboard
  static const String dashboardSummary = '$baseUrl/dashboard/summary';

  //Bitácora
  static const String bitacoras = '$baseUrl/bitacoras';

  //Clima (fuente externa, no pasa por nuestro gateway)
  static const String openMeteoBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  //Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
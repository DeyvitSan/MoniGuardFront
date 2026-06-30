abstract final class ApiConstants {
  static const String _host = '10.0.2.2';
  static const int    _port = 3000;

  static const String baseUrl  = 'http://192.168.100.8:3000/api/v1';

  //Endpoints
  static const String login    = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  //Dash
  static const String dashboardSummary = '$baseUrl/dashboard/summary';


  //Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  //Bitacora
  static const String bitacoras = '$baseUrl/bitacoras';

  //Clima extremo
  static const String openMeteoBaseUrl = 'https://api.open-meteo.com/v1/forecast';

}
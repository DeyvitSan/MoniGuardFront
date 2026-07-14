import 'entities/dashboard_summary.dart';

abstract interface class DashboardRepository {
  // El token se lee de SessionService internamente, ya no se pasa por parámetro
  Future<DashboardSummary> getSummary();
}

class DashboardException implements Exception {
  final String message;
  final int?   statusCode;
  const DashboardException({required this.message, this.statusCode});
}
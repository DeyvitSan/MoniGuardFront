import '../models/dashboard_summary.dart';

abstract interface class IDashboardRepository {
  // Obtiene el resumen del dashboard para el usuario autenticado.
  // Requiere el [accessToken] para el header Authorization.
  Future<DashboardSummary> getSummary({required String accessToken});
}

class DashboardException implements Exception {
  final String message;
  final int?   statusCode;
  const DashboardException({required this.message, this.statusCode});
}
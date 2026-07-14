import 'entities/dashboard_summary.dart';

abstract interface class DashboardRepository {
  //Obtiene el resumen del dashboard para el usuario autenticado.
  Future<DashboardSummary> getSummary({required String accessToken});
}

class DashboardException implements Exception {
  final String message;
  final int?   statusCode;
  const DashboardException({required this.message, this.statusCode});
}
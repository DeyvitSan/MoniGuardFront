import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/session/session_service.dart';
import '../../domain/dashboard_repository.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final http.Client _client;
  final SessionService _session;

  DashboardRepositoryImpl({
    http.Client? client,
    SessionService? session,
  })  : _client = client ?? http.Client(),
        _session = session ?? SessionService();

  @override
  Future<DashboardSummary> getSummary() async {
    final token = await _session.readToken();
    if (token == null || token.trim().isEmpty) {
      throw const DashboardException(
        statusCode: 401,
        message: 'Sesión expirada. Inicia sesión de nuevo',
      );
    }

    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.dashboardSummary),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept':        'application/json',
        },
      ).timeout(ApiConstants.connectTimeout);

      return _handleResponse(response);

    } on TimeoutException {
      throw const DashboardException(
        message: 'El servidor tardó demasiado. Intenta de nuevo',
      );
    } on http.ClientException {
      throw const DashboardException(
        message: 'Sin conexión. Verifica tu red e intenta de nuevo',
      );
    }
  }

  // ── Parseo ────────────────────────────────────────────────────────────────
  DashboardSummary _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    switch (response.statusCode) {
      case 200:
        return DashboardSummary.fromJson(body);
      case 401:
        throw const DashboardException(
            statusCode: 401, message: 'Sesión expirada. Inicia sesión de nuevo');
      case 404:
        throw const DashboardException(
            statusCode: 404, message: 'No tienes parcelas registradas aún');
      default:
        throw DashboardException(
            statusCode: response.statusCode,
            message: 'Error del servidor. Intenta más tarde');
    }
  }
}
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../domain/dashboard_repository.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final http.Client _client;

  //Cambia a false cuando el backend tenga el endpoint listo
  static const bool _useMock = true;

  DashboardRepositoryImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<DashboardSummary> getSummary({required String accessToken}) async {
    if (_useMock) return _mockSummary();

    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.dashboardSummary),
        headers: {
          'Authorization': 'Bearer $accessToken',
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

  //TODO(equipo): eliminar este mock (o poner _useMock = false) cuando el
  //pipeline de ML + backend real de dashboard esté conectado.
  Future<DashboardSummary> _mockSummary() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return DashboardSummary.fromJson({
      'parcela': {
        'id':        'mock-uuid-001',
        'nombre':    'Parcela El Zapotal',
        'ubicacion': 'Pichucalco, Chiapas',
      },
      'clima': {
        'temperatura':   28.4,
        'humedad':       87.2,
        'precipitacion': 12.5,
        'actualizadoEn': DateTime.now().toIso8601String(),
      },
      'riesgo': {
        'nivel':       'alto',
        'porcentaje':  78,
        'descripcion': 'Condiciones favorables para el avance de moniliasis',
      },
      'alertasActivas': 2,
      'ultimaBitacora': DateTime.now()
          .subtract(const Duration(hours: 30))
          .toIso8601String(),
    });
  }
}
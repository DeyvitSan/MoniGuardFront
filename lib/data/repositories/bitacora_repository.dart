import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/api_constants.dart';
import '../../domain/interfaces/i_bitacora_repository.dart';
import '../../domain/models/bitacora.dart';

class BitacoraRepository implements IBitacoraRepository {
  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  static const _storageKey = 'bitacoras_pendientes';

  BitacoraRepository({http.Client? client, FlutterSecureStorage? secureStorage})
      : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<ClimaPrevio> getClimaDestino({
    required double lat,
    required double lng,
  }) async {
    final uri = Uri.parse(ApiConstants.openMeteoBaseUrl).replace(queryParameters: {
      'latitude':  lat.toString(),
      'longitude': lng.toString(),
      'current':   'temperature_2m,relative_humidity_2m,precipitation',
      'timezone':  'America/Mexico_City',
    });

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw const BitacoraException('No se pudo obtener el clima del destino');
      }
      return ClimaPrevio.fromOpenMeteo(jsonDecode(response.body) as Map<String, dynamic>);
    } on TimeoutException {
      throw const BitacoraException('Sin conexión para consultar el clima. Verifica antes de salir');
    } on http.ClientException {
      throw const BitacoraException('Sin conexión para consultar el clima. Verifica antes de salir');
    }
  }

  @override
  Future<void> guardarLocal(Bitacora bitacora) async {
    final pendientes = await _leerPendientesRaw();
    pendientes.add(bitacora.toLocalJson());
    await _secureStorage.write(key: _storageKey, value: jsonEncode(pendientes));
  }

  @override
  Future<List<Bitacora>> listarPendientes() async {
    final pendientes = await _leerPendientesRaw();
    return pendientes.map((j) => Bitacora.fromLocalJson(j)).toList();
  }

  @override
  Future<int> sincronizar({required String accessToken}) async {
    final pendientes = await _leerPendientesRaw();
    if (pendientes.isEmpty) return 0;

    int subidas = 0;
    final restantes = <Map<String, dynamic>>[];

    for (final j in pendientes) {
      final bitacora = Bitacora.fromLocalJson(j);
      try {
        final response = await _client.post(
          Uri.parse(ApiConstants.bitacoras),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(bitacora.toJson()),
        ).timeout(ApiConstants.connectTimeout);

        if (response.statusCode == 201) {
          subidas++;
        } else {
          restantes.add(j); // se queda pendiente si falló
        }
      } on TimeoutException {
        restantes.add(j);
      } on http.ClientException {
        restantes.add(j); // sin internet, se queda para después
      }
    }

    await _secureStorage.write(key: _storageKey, value: jsonEncode(restantes));
    return subidas;
  }

  @override
  Future<List<Bitacora>> listarRemotas({required String accessToken}) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.bitacoras),
        headers: {'Authorization': 'Bearer $accessToken'},
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode != 200) {
        throw const BitacoraException('No se pudieron cargar las bitácoras');
      }
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((j) => Bitacora.fromJson(j as Map<String, dynamic>)).toList();
    } on TimeoutException {
      throw const BitacoraException('Sin conexión. Mostrando datos guardados');
    }
  }

  Future<List<Map<String, dynamic>>> _leerPendientesRaw() async {
    try {
      final raw = await _secureStorage.read(key: _storageKey);
      if (raw == null) return [];
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
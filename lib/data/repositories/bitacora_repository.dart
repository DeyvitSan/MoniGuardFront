import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/api_constants.dart';
import '../../core/session/session_service.dart';
import '../../domain/interfaces/i_bitacora_repository.dart';
import '../../domain/models/bitacora.dart';

class BitacoraRepository implements IBitacoraRepository {
  final http.Client _client;
  final FlutterSecureStorage _secureStorage;
  final SessionService _session;

  static const _storageKey = 'bitacoras_pendientes';

  BitacoraRepository({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
    SessionService? session,
  })  : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _session = session ?? SessionService();

  @override
  Future<ClimaPrevio> getClimaDestino({
    required double lat,
    required double lng,
  }) async {
    final uri =
    Uri.parse(ApiConstants.openMeteoBaseUrl).replace(queryParameters: {
      'latitude': lat.toString(),
      'longitude': lng.toString(),
      'current': 'temperature_2m,relative_humidity_2m,precipitation',
      'timezone': 'America/Mexico_City',
    });

    try {
      final response =
      await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw const BitacoraException('No se pudo obtener el clima del destino');
      }
      return ClimaPrevio.fromOpenMeteo(
          jsonDecode(response.body) as Map<String, dynamic>);
    } on TimeoutException {
      throw const BitacoraException(
          'Sin conexión para consultar el clima. Verifica antes de salir');
    } on http.ClientException {
      throw const BitacoraException(
          'Sin conexión para consultar el clima. Verifica antes de salir');
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
  Future<SyncResult> sincronizar() async {
    // El token se lee de la única fuente de verdad. Si no hay, fallamos
    // EXPLÍCITO en vez de mandar "Bearer " vacío y provocar un 401 silencioso.
    final token = await _session.readToken();
    if (token == null || token.trim().isEmpty) {
      throw const UnauthorizedException(
          'No hay sesión activa. Inicia sesión para sincronizar.');
    }

    final pendientes = await _leerPendientesRaw();
    if (pendientes.isEmpty) {
      return const SyncResult(outcome: SyncOutcome.nothingPending);
    }

    int subidas = 0;
    int fallidas = 0;
    final restantes = <Map<String, dynamic>>[];

    for (var i = 0; i < pendientes.length; i++) {
      final j = pendientes[i];
      final bitacora = Bitacora.fromLocalJson(j);
      try {
        final response = await _client
            .post(
          Uri.parse(ApiConstants.bitacoras),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(bitacora.toJson()),
        )
            .timeout(ApiConstants.connectTimeout);

        final code = response.statusCode;
        if (code == 201) {
          subidas++;
        } else if (code == 401 || code == 403) {
          // Token inválido/expirado: reintentar el resto con el mismo token
          // fallaría igual. Preservamos TODO lo no subido y abortamos explícito.
          restantes.addAll(pendientes.sublist(i));
          await _secureStorage.write(
              key: _storageKey, value: jsonEncode(restantes));
          throw const UnauthorizedException();
        } else {
          // 4xx de datos o 5xx del servidor: se conserva y se reintenta luego.
          fallidas++;
          restantes.add(j);
        }
      } on TimeoutException {
        fallidas++;
        restantes.add(j);
      } on http.ClientException {
        fallidas++;
        restantes.add(j); // sin internet, se queda para después
      }
    }

    await _secureStorage.write(key: _storageKey, value: jsonEncode(restantes));

    if (fallidas == 0) {
      return SyncResult(outcome: SyncOutcome.allUploaded, uploaded: subidas);
    }
    if (subidas == 0) {
      return SyncResult(outcome: SyncOutcome.allFailed, failed: fallidas);
    }
    return SyncResult(
        outcome: SyncOutcome.partial, uploaded: subidas, failed: fallidas);
  }

  @override
  Future<List<Bitacora>> listarRemotas() async {
    final token = await _session.readToken();
    if (token == null || token.trim().isEmpty) {
      throw const UnauthorizedException();
    }
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.bitacoras),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const UnauthorizedException();
      }
      if (response.statusCode != 200) {
        throw const BitacoraException('No se pudieron cargar las bitácoras');
      }
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((j) => Bitacora.fromJson(j as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw const BitacoraException('Sin conexión. Mostrando datos guardados');
    } on http.ClientException {
      // Antes NO se capturaba: sin internet lanzaba excepción no controlada.
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
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/session/session_service.dart';
import '../../domain/entities/parcela.dart';
import '../../domain/parcela_repository.dart';

class ParcelaRepositoryImpl implements ParcelaRepository {
  final http.Client _client;
  final SessionService _session;

  ParcelaRepositoryImpl({
    http.Client? client,
    SessionService? session,
  })  : _client = client ?? http.Client(),
        _session = session ?? SessionService();

  Future<String> _requireToken() async {
    final token = await _session.readToken();
    if (token == null || token.trim().isEmpty) {
      throw const ParcelaException(
        message: 'No hay sesión activa. Inicia sesión de nuevo.',
        statusCode: 401,
      );
    }
    return token;
  }

  @override
  Future<Parcela> crear({
    required String nombre,
    required String ubicacion,
    required double hectareas,
    String cultivo = 'cacao',
    double? destinoLat,
    double? destinoLng,
  }) async {
    final token = await _requireToken();

    try {
      final response = await _client
          .post(
        Uri.parse(ApiConstants.parcelas),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre':     nombre,
          'ubicacion':  ubicacion,
          'hectareas':  hectareas,
          'cultivo':    cultivo,
          'destinoLat': destinoLat,
          'destinoLng': destinoLng,
        }),
      )
          .timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 201) {
        return Parcela.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ParcelaException(
          message: 'Tu sesión expiró. Inicia sesión de nuevo.',
          statusCode: 401,
        );
      }
      if (response.statusCode == 409) {
        // El backend ya rechazó esto porque el usuario YA tiene una
        // parcela — no es un error real desde el punto de vista del
        // usuario, solo significa que puede pasar directo a Home.
        throw ParcelaException(
          message: 'Ya tienes una parcela registrada.',
          statusCode: 409,
        );
      }
      throw ParcelaException(
        message: 'No se pudo crear la parcela. Intenta de nuevo.',
        statusCode: response.statusCode,
      );

    } on TimeoutException {
      throw const ParcelaException(
        message: 'El servidor tardó demasiado. Intenta de nuevo.',
      );
    } on http.ClientException {
      throw const ParcelaException(
        message: 'Sin conexión. Verifica tu red e intenta de nuevo.',
      );
    }
  }

  @override
  Future<List<Parcela>> listar() async {
    final token = await _requireToken();

    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.parcelas),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ParcelaException(
          message: 'Tu sesión expiró. Inicia sesión de nuevo.',
          statusCode: 401,
        );
      }
      if (response.statusCode != 200) {
        throw const ParcelaException(message: 'No se pudieron cargar tus parcelas.');
      }

      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((j) => Parcela.fromJson(j as Map<String, dynamic>)).toList();

    } on TimeoutException {
      throw const ParcelaException(message: 'El servidor tardó demasiado.');
    } on http.ClientException {
      throw const ParcelaException(message: 'Sin conexión.');
    }
  }

  @override
  Future<bool> tieneParcela() async {
    try {
      return await _tieneParcelaIntento();
    } on ParcelaException catch (e) {
      // Si fue por sesión expirada, no tiene caso reintentar.
      if (e.statusCode == 401) rethrow;
      // Un solo reintento — cubre el caso típico de un hiccup momentáneo
      // (arranque en frío del backend, blip de red) sin duplicar la
      // espera del usuario más de lo necesario.
      return await _tieneParcelaIntento();
    }
  }

  Future<bool> _tieneParcelaIntento() async {
    final token = await _requireToken();

    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.parcelasTiene),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ParcelaException(
          message: 'Tu sesión expiró. Inicia sesión de nuevo.',
          statusCode: 401,
        );
      }
      if (response.statusCode != 200) {
        // Antes esto asumía "no tiene parcela" ante CUALQUIER error, lo
        // cual podía mandar a un usuario que SÍ tiene parcela de vuelta
        // al formulario de creación (y, si insistía, terminaba con una
        // segunda parcela). Ahora se distingue: solo un 200 confirma de
        // verdad; cualquier otra cosa es "no sabemos", no "no tiene".
        throw ParcelaException(
          message: 'No se pudo confirmar tu parcela. Intenta de nuevo.',
          statusCode: response.statusCode,
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['hasParcela'] as bool? ?? false;

    } on TimeoutException {
      throw const ParcelaException(message: 'El servidor tardó demasiado.');
    } on http.ClientException {
      throw const ParcelaException(message: 'Sin conexión.');
    }
  }
}
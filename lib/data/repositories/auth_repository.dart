// lib/data/repositories/auth_repository.dart
//
// Implementación HTTP de IAuthRepository — v2 (agrega register).
// Solo cambia este archivo cuando cambie la API. Nada de presentación aquí.

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../domain/interfaces/i_auth_repository.dart';
import '../../domain/models/auth_response.dart';

class AuthRepository implements IAuthRepository {
  final http.Client _client;

  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  // ── Sign In ───────────────────────────────────────────────────────────────
  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _post(
      url:  ApiConstants.login,
      body: {'email': email, 'password': password},
    );
  }

  // ── Register ──────────────────────────────────────────────────────────────
  @override
  Future<AuthResponse> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    return _post(
      url:  ApiConstants.register,
      body: {'nombre': nombre, 'email': email, 'password': password},
    );
  }

  // ── Helper compartido ─────────────────────────────────────────────────────
  Future<AuthResponse> _post({
    required String url,
    required Map<String, String> body,
  }) async {
    try {
      final response = await _client
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept':       'application/json',
        },
        body: jsonEncode(body),
      )
          .timeout(ApiConstants.connectTimeout);

      return _handleResponse(response);

    } on TimeoutException {
      throw const AuthException(
        message: 'El servidor tardó demasiado. Intenta de nuevo',
      );
    } on http.ClientException {
      throw const AuthException(
        message: 'Sin conexión. Verifica tu red e intenta de nuevo',
      );
    }
  }

  // ── Parseo de respuesta ───────────────────────────────────────────────────
  AuthResponse _handleResponse(http.Response response) {
    final Map<String, dynamic> body =
    jsonDecode(response.body) as Map<String, dynamic>;

    switch (response.statusCode) {
      case 200:
      case 201:
        return AuthResponse.fromJson(body);
      case 401:
        throw AuthException(statusCode: 401,
            message: body['message'] as String? ?? 'Credenciales incorrectas');
      case 409:
        throw AuthException(statusCode: 409,
            message: body['message'] as String? ?? 'El correo ya está registrado');
      case 422:
        throw AuthException(statusCode: 422,
            message: body['message'] as String? ?? 'Datos inválidos');
      default:
        throw AuthException(statusCode: response.statusCode,
            message: 'Error del servidor. Intenta más tarde');
    }
  }
}
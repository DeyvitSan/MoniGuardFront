// lib/domain/interfaces/i_auth_repository.dart
// Contrato de autenticación — v2 (agrega register).
// Ningún widget importa este archivo directamente, solo los Controllers.

import '../models/auth_response.dart';

abstract interface class IAuthRepository {
  /// Autentica un usuario existente.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario y retorna sesión activa.
  /// El backend crea la cuenta Y devuelve tokens — el usuario entra directo.
  Future<AuthResponse> register({
    required String nombre,
    required String email,
    required String password,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Excepción tipada — compartida por signIn y register
// ─────────────────────────────────────────────────────────────────────────────
class AuthException implements Exception {
  final String message;
  final int?   statusCode;

  const AuthException({required this.message, this.statusCode});

  @override
  String toString() => 'AuthException($statusCode): $message';
}
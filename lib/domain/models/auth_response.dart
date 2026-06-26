import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String nombre;
  final String email;
  final String rol;

  const AuthUser({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id:     json['id']     as String,
    nombre: json['nombre'] as String,
    email:  json['email']  as String,
    rol:    json['rol']    as String,
  );
}

@immutable
class AuthResponse {
  final String   accessToken;
  final String   refreshToken;
  final AuthUser user;
  final int      expiresIn;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken:  json['accessToken']  as String,
    refreshToken: json['refreshToken'] as String,
    user:         AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    expiresIn:    json['expiresIn']    as int,
  );
}
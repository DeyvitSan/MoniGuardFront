import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String  id;
  final String  nombre;
  final String  email;
  final String? createdAt;

  const AuthUser({
    required this.id,
    required this.nombre,
    required this.email,
    this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id:        json['id']        as String,
    nombre:    json['nombre']    as String,
    email:     json['email']     as String,
    createdAt: json['createdAt'] as String?,
  );
}

@immutable
class AuthResponse {
  final String   accessToken;
  final String   refreshToken;
  final AuthUser user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken:  json['accessToken']  as String,
    refreshToken: json['refreshToken'] as String,
    user:         AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  );
}
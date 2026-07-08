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
import 'package:flutter/foundation.dart';

@immutable
class ProfileUser {
  final String name;
  final String email;
  final String? passwordHash;
  final String? parcelaNombre;
  final String? parcelaUbicacion;
  final double? parcelaHectareas;

  const ProfileUser({
    required this.name,
    required this.email,
    this.passwordHash,
    this.parcelaNombre,
    this.parcelaUbicacion,
    this.parcelaHectareas,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) => ProfileUser(
    name: (json['nombre'] ?? json['name'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    passwordHash: json['passwordHash']?.toString(),
    parcelaNombre: json['parcelaNombre']?.toString(),
    parcelaUbicacion: json['parcelaUbicacion']?.toString(),
    parcelaHectareas: (json['parcelaHectareas'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'nombre': name,
    'email': email,
    'passwordHash': passwordHash,
    'parcelaNombre': parcelaNombre,
    'parcelaUbicacion': parcelaUbicacion,
    'parcelaHectareas': parcelaHectareas,
  };
}
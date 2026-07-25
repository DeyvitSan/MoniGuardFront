import 'package:flutter/foundation.dart';

@immutable
class ProfileUser {
  final String name;
  final String email;
  final String? passwordHash;
  final String? parcelaNombre;

  const ProfileUser({
    required this.name,
    required this.email,
    this.passwordHash,
    this.parcelaNombre,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) => ProfileUser(
    name: (json['nombre'] ?? json['name'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    passwordHash: json['passwordHash']?.toString(),
    parcelaNombre: json['parcelaNombre']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'nombre': name,
    'email': email,
    'passwordHash': passwordHash,
    'parcelaNombre': parcelaNombre,
  };
}
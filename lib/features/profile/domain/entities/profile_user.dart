import 'package:flutter/foundation.dart';

@immutable
class ProfileUser {
  final String name;
  final String email;

  const ProfileUser({required this.name, required this.email});

  factory ProfileUser.fromJson(Map<String, dynamic> json) => ProfileUser(
        name: (json['nombre'] ?? json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'nombre': name,
        'email': email,
      };
}

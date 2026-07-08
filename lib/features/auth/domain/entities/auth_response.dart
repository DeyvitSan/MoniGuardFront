import 'package:flutter/foundation.dart';

import 'auth_user.dart';

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
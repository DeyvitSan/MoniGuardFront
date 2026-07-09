import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/session/session_service.dart';
import '../../../../data/repositories/local_storage_service.dart';
import '../../../../domain/interfaces/i_local_storage_service.dart';
import '../../domain/entities/profile_user.dart';
import '../../domain/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({http.Client? client, SessionService? session, ILocalStorageService? storage})
      : _client = client ?? http.Client(),
        _session = session ?? SessionService(),
        _storage = storage ?? LocalStorageService();

  final http.Client _client;
  final SessionService _session;
  final ILocalStorageService _storage;

  @override
  Future<ProfileUser> getProfile() async {
    final token = await _session.readToken();
    if (token == null || token.trim().isEmpty) {
      throw const ProfileException('No hay sesión activa');
    }

    try {
      final response = await _client
          .get(
            Uri.parse(ApiConstants.profileMe),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final profile = ProfileUser.fromJson(data);
          await _storage.setUserName(value: profile.name);
          await _storage.setUserEmail(email: profile.email);
          return profile;
        }
      }

      throw const ProfileException('No se pudo cargar el perfil');
    } on TimeoutException {
      throw const ProfileException('Sin conexión. Intenta nuevamente');
    } on http.ClientException {
      throw const ProfileException('Sin conexión. Intenta nuevamente');
    }
  }

  @override
  Future<ProfileUser> updateName({required String name}) async {
    final token = await _session.readToken();
    if (token == null || token.trim().isEmpty) {
      throw const ProfileException('No hay sesión activa');
    }

    try {
      final response = await _client
          .put(
            Uri.parse(ApiConstants.profileUpdate),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            body: jsonEncode({'nombre': name}),
          )
          .timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final profile = ProfileUser.fromJson(data);
          await _storage.setUserName(value: profile.name);
          await _storage.setUserEmail(email: profile.email);
          return profile;
        }
      }

      throw const ProfileException('No se pudo actualizar el nombre');
    } on TimeoutException {
      throw const ProfileException('Sin conexión. Intenta nuevamente');
    } on http.ClientException {
      throw const ProfileException('Sin conexión. Intenta nuevamente');
    }
  }
}

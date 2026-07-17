import 'package:flutter/foundation.dart';

import '../../../../core/session/session_service.dart';
import '../../../onboarding/data/repositories/local_storage_service_impl.dart';
import '../../../onboarding/domain/local_storage_service.dart';
import '../../domain/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required ProfileRepository repository,
    LocalStorageService? storageService,
    SessionService? sessionService,
  })  : _repository = repository,
        _storage = storageService ?? LocalStorageServiceImpl(),
        _session = sessionService ?? SessionService();

  final ProfileRepository _repository;
  final LocalStorageService _storage;
  final SessionService _session;

  String _name = 'Usuario';
  String _email = 'Sin correo';
  bool _isLoading = false;
  String? _errorMessage;

  String get name => _name;
  String get email => _email;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$a$b'.toUpperCase();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cachedName = await _storage.getUserName();
      final cachedEmail = await _storage.getUserEmail();
      if (cachedName != null && cachedName.trim().isNotEmpty) {
        _name = cachedName.trim();
      }
      if (cachedEmail != null && cachedEmail.trim().isNotEmpty) {
        _email = cachedEmail.trim();
      }

      final profile = await _repository.getProfile();
      _name = profile.name;
      _email = profile.email;
      await _storage.setUserName(value: _name);
      await _storage.setUserEmail(email: _email);
    } catch (e) {
      final message = e.toString();
      if (message.contains('ProfileException')) {
        _errorMessage = null;
      } else {
        _errorMessage = message;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateName(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      _errorMessage = 'El nombre no puede quedar vacío.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateName(name: trimmed);
      _name = updated.name.trim().isNotEmpty ? updated.name : trimmed;
      _email = updated.email.trim().isNotEmpty ? updated.email : _email;
      await _storage.setUserName(value: _name);
      await _storage.setUserEmail(email: _email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword({required String currentPassword, required String newPassword}) async {
    if (currentPassword.trim().isEmpty || newPassword.trim().isEmpty) {
      _errorMessage = 'Completa ambas contraseñas.';
      notifyListeners();
      return false;
    }

    if (newPassword.length < 8) {
      _errorMessage = 'La nueva contraseña debe tener al menos 8 caracteres.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _session.clear();
      await _storage.clearAll();
      _name = 'Usuario';
      _email = 'Sin correo';
      _errorMessage = null;
    } catch (e) {
      debugPrint('profile logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

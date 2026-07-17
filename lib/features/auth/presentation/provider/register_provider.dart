import 'package:flutter/foundation.dart';

import '../../../onboarding/data/repositories/local_storage_service_impl.dart';
import '../../domain/auth_repository.dart';
import '../../domain/entities/auth_response.dart';

enum RegisterStatus { idle, loading, success, failure }

class RegisterProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  RegisterProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  RegisterStatus _status         = RegisterStatus.idle;
  String?        _errorMessage;
  bool           _passwordVisible = false;
  bool           _confirmVisible  = false;
  AuthResponse?  _authResponse;

  RegisterStatus get status          => _status;
  String?        get errorMessage    => _errorMessage;
  bool           get passwordVisible => _passwordVisible;
  bool           get confirmVisible  => _confirmVisible;
  bool           get isLoading       => _status == RegisterStatus.loading;
  AuthResponse?  get authResponse    => _authResponse;

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void toggleConfirmVisibility() {
    _confirmVisible = !_confirmVisible;
    notifyListeners();
  }

  // Nota: NO guarda token en SessionService a propósito — el registro
  // no auto-loguea, redirige a login para que el usuario entre manualmente.
  Future<void> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    _setLoading();

    try {
      _authResponse = await _authRepository.register(
        nombre:   nombre,
        email:    email,
        password: password,
      );
      await LocalStorageServiceImpl().setUserName(value: nombre);
      await LocalStorageServiceImpl().setUserEmail(email: email);
      _status       = RegisterStatus.success;
      _errorMessage = null;

    } on AuthException catch (e) {
      _status       = RegisterStatus.failure;
      _errorMessage = e.message;

    } catch (_) {
      _status       = RegisterStatus.failure;
      _errorMessage = 'Ocurrió un error inesperado. Intenta más tarde';

    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _status          = RegisterStatus.idle;
    _errorMessage    = null;
    _passwordVisible = false;
    _confirmVisible  = false;
    _authResponse    = null;
    notifyListeners();
  }

  void _setLoading() {
    _status       = RegisterStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }
}
import 'package:flutter/foundation.dart';

import '../../../domain/interfaces/i_auth_repository.dart';
import '../../../domain/models/auth_response.dart';

enum RegisterStatus { idle, loading, success, failure }

class RegisterController extends ChangeNotifier {
  final IAuthRepository _authRepository;

  RegisterController({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  //Estado
  RegisterStatus _status         = RegisterStatus.idle;
  String?        _errorMessage;
  bool           _passwordVisible = false;
  bool           _confirmVisible  = false;
  AuthResponse?  _authResponse;

  //Getters
  RegisterStatus get status          => _status;
  String?        get errorMessage    => _errorMessage;
  bool           get passwordVisible => _passwordVisible;
  bool           get confirmVisible  => _confirmVisible;
  bool           get isLoading       => _status == RegisterStatus.loading;
  AuthResponse?  get authResponse    => _authResponse;

  //Toggles de visibilidad
  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void toggleConfirmVisibility() {
    _confirmVisible = !_confirmVisible;
    notifyListeners();
  }

  //Registro
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

  //Reset
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
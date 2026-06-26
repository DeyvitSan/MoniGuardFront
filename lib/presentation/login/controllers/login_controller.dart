import 'package:flutter/foundation.dart';

import '../../../domain/interfaces/i_auth_repository.dart';
import '../../../domain/models/auth_response.dart';

enum LoginStatus { idle, loading, success, failure }

class LoginController extends ChangeNotifier {
  //DIP: depende de la abstracción, no de AuthRepository concreto
  final IAuthRepository _authRepository;

  LoginController({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  //Estado
  LoginStatus  _status          = LoginStatus.idle;
  String?      _errorMessage;
  bool         _passwordVisible = false;
  AuthResponse? _authResponse;   // guarda tokens para pasarlos al storage

  //Getters públicos
  LoginStatus   get status          => _status;
  String?       get errorMessage    => _errorMessage;
  bool          get passwordVisible => _passwordVisible;
  bool          get isLoading       => _status == LoginStatus.loading;
  AuthResponse? get authResponse    => _authResponse;

  //Toggle visibilidad contraseña
  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  //Autenticación real
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();

    try {
      _authResponse = await _authRepository.signIn(
        email:    email,
        password: password,
      );
      _status       = LoginStatus.success;
      _errorMessage = null;

    } on AuthException catch (e) {
      //Error tipado del repositorio — mensaje ya es amigable
      _status       = LoginStatus.failure;
      _errorMessage = e.message;

    } catch (_) {
      //Cualquier error inesperado — nunca exponemos detalles internos
      _status       = LoginStatus.failure;
      _errorMessage = 'Ocurrió un error inesperado. Intenta más tarde';

    } finally {
      notifyListeners();
    }
  }

  //Reset
  void reset() {
    _status          = LoginStatus.idle;
    _errorMessage    = null;
    _passwordVisible = false;
    _authResponse    = null;
    notifyListeners();
  }

  void _setLoading() {
    _status       = LoginStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }
}
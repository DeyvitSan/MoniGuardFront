import 'package:flutter/foundation.dart';

import '../../../../core/session/session_service.dart';
import '../../../onboarding/data/repositories/local_storage_service_impl.dart';
import '../../domain/auth_repository.dart';
import '../../domain/entities/auth_response.dart';

enum LoginStatus { idle, loading, success, failure }

class LoginProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  LoginStatus  _status          = LoginStatus.idle;
  String?      _errorMessage;
  bool         _passwordVisible = false;
  AuthResponse? _authResponse;

  LoginStatus   get status          => _status;
  String?       get errorMessage    => _errorMessage;
  bool          get passwordVisible => _passwordVisible;
  bool          get isLoading       => _status == LoginStatus.loading;
  AuthResponse? get authResponse    => _authResponse;

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

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

      await SessionService().saveToken(_authResponse!.accessToken);
      await LocalStorageServiceImpl().setUserName(value: _authResponse!.user.nombre);
      await LocalStorageServiceImpl().setUserEmail(email: _authResponse!.user.email);
      _status       = LoginStatus.success;
      _errorMessage = null;

    } on AuthException catch (e) {
      _status       = LoginStatus.failure;
      _errorMessage = e.message;

    } catch (_) {
      _status       = LoginStatus.failure;
      _errorMessage = 'Ocurrió un error inesperado. Intenta más tarde';

    } finally {
      notifyListeners();
    }
  }

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
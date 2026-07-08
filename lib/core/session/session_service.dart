// core/session/session_service.dart
// Única fuente de verdad para el token JWT. El login guarda el token aquí una
// sola vez; el resto de la app lo LEE de aquí, nunca se pasa por constructores.
// Esto elimina la clase de bug "se me olvidó pasar el accessToken" que provocaba
// 401 silenciosos.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'access_token';

  SessionService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Llamar esto DESPUÉS de un login exitoso (integración pendiente en tu
  /// auth flow): await SessionService().saveToken(respuesta.accessToken);
  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> clear() => _storage.delete(key: _tokenKey);

  Future<bool> get hasValidToken async {
    final t = await readToken();
    return t != null && t.trim().isNotEmpty;
  }
}
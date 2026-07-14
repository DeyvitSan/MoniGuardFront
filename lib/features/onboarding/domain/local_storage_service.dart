// features/onboarding/domain/local_storage_service.dart
abstract interface class LocalStorageService {
  // Persiste el flag que indica que el usuario ya vio el onboarding.
  Future<void> setHasSeenOnboarding({required bool value});

  // Lee el flag de onboarding. Retorna `false` si nunca se ha establecido.
  Future<bool> getHasSeenOnboarding();

  // Persistir/leer datos del usuario autenticado.
  Future<void> setUserEmail({required String email});
  Future<String?> getUserEmail();
  Future<void> setUserName({required String value});
  Future<String?> getUserName();

  // Limpia todo el storage (útil para logout / remote wipe).
  Future<void> clearAll();
}
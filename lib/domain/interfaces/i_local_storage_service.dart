abstract interface class ILocalStorageService {
  // Persiste el flag que indica que el usuario ya vio el onboarding.
  Future<void> setHasSeenOnboarding({required bool value});

  // Lee el flag de onboarding. Retorna `false` si nunca se ha establecido.
  Future<bool> getHasSeenOnboarding();

  // Limpia todo el storage (útil para logout / remote wipe).
  Future<void> clearAll();
}
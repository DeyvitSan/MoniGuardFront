import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/interfaces/i_local_storage_service.dart';

class LocalStorageService implements ILocalStorageService {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';

  @override
  Future<void> setHasSeenOnboarding({required bool value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, value);
  }

  @override
  Future<bool> getHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<void> setUserEmail({required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, email);
  }

  @override
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  @override
  Future<void> setUserName({required String value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, value);
  }

  @override
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }
}
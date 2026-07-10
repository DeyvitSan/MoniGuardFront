// features/onboarding/data/repositories/local_storage_service_impl.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/local_storage_service.dart';

class LocalStorageServiceImpl implements LocalStorageService {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

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
}
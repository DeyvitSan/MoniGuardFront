import 'package:flutter/material.dart';

import '../../../core/di/injection_container.dart';
import '../../onboarding/domain/local_storage_service.dart';

class ProfileController extends ChangeNotifier {
  String name = 'Juan Pérez';
  String email = 'juan@example.com';

  String get initials {
    final parts = name.split(' ');
    final a = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$a$b'.toUpperCase();
  }

  void update({String? name, String? email}) {
    if (name != null) this.name = name;
    if (email != null) this.email = email;
    notifyListeners();
  }

  Future<void> logout() async {
    // Limpia almacenamiento local (tokens, flags, etc.)
    try {
      final storage = getIt<LocalStorageService>();
      await storage.clearAll();
      debugPrint('logout: local storage cleared');
    } catch (e) {
      debugPrint('logout error: $e');
    }
    notifyListeners();
  }
}

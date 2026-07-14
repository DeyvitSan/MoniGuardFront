import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../provider/profile_provider.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({ProfileProvider? provider})
      : _provider = provider ?? GetIt.instance<ProfileProvider>();

  final ProfileProvider _provider;

  String get name => _provider.name;
  String get email => _provider.email;
  String get initials => _provider.initials;
  bool get isLoading => _provider.isLoading;
  String? get errorMessage => _provider.errorMessage;

  Future<void> logout() => _provider.logout();

  @override
  void addListener(VoidCallback listener) {
    _provider.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _provider.removeListener(listener);
  }
}

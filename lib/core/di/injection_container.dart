import 'package:get_it/get_it.dart';
import '../../features/auth/di/injection_auth.dart';
import '../../features/bitacora/di/injection_bitacora.dart';
import '../../features/home/di/injection_home.dart';
import '../../features/onboarding/di/injection_onboarding.dart';
import '../../features/parcela/di/injection_parcela.dart';
import '../../features/profile/di/injection_profile.dart';

import '../session/session_service.dart';
import '../network/connectivity_service.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt.registerLazySingleton<SessionService>(() => SessionService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  initAuthDependencies(getIt);
  initParcelaDependencies(getIt);
  initBitacoraDependencies(getIt);
  initHomeDependencies(getIt);
  initOnboardingDependencies(getIt);
  initProfileDependencies(getIt);
}
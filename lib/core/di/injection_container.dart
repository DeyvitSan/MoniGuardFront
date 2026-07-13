import 'package:get_it/get_it.dart';
import '../../features/auth/di/injection_auth.dart';
import '../../features/bitacora/di/injection_bitacora.dart';
import '../../features/home/di/injection_home.dart';
import '../../features/onboarding/di/injection_onboarding.dart';
import '../../features/parcela/di/injection_parcela.dart';



import '../session/session_service.dart';
import '../network/connectivity_service.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core (compartido por todas las features)
  getIt.registerLazySingleton<SessionService>(() => SessionService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // ── Cada feature registra las suyas aquí, según se vayan migrando:
   initAuthDependencies(getIt);
   initBitacoraDependencies(getIt);
   initHomeDependencies(getIt);
   initOnboardingDependencies(getIt);
   initParcelaDependencies(getIt);
}
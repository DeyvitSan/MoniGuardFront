import 'package:get_it/get_it.dart';
import '../../features/bitacora/di/injection_bitacora.dart';


import '../session/session_service.dart';
import '../network/connectivity_service.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core (compartido por todas las features)
  getIt.registerLazySingleton<SessionService>(() => SessionService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // ── Cada feature registra las suyas aquí, según se vayan migrando:
  // initAuthDependencies(getIt);
   initBitacoraDependencies(getIt);
}
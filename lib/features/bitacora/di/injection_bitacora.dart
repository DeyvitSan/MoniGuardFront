import 'package:get_it/get_it.dart';

import '../../../core/session/session_service.dart';
import '../../parcela/domain/parcela_repository.dart';
import '../data/repositories/bitacora_repository_impl.dart';
import '../domain/bitacora_repository.dart';
import '../presentation/provider/bitacora_provider.dart';

void initBitacoraDependencies(GetIt getIt) {
  getIt.registerLazySingleton<BitacoraRepository>(
        () => BitacoraRepositoryImpl(session: getIt<SessionService>()),
  );
  getIt.registerFactory<BitacoraProvider>(
        () => BitacoraProvider(
      repository: getIt<BitacoraRepository>(),
      parcelaRepository: getIt<ParcelaRepository>(),
    ),
  );
}
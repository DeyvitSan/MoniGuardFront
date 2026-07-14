import 'package:get_it/get_it.dart';
import '../../../core/session/session_service.dart';
import '../data/repositories/parcela_repository_impl.dart';
import '../domain/parcela_repository.dart';
import '../presentation/provider/parcela_provider.dart';

void initParcelaDependencies(GetIt getIt) {
  getIt.registerLazySingleton<ParcelaRepository>(
        () => ParcelaRepositoryImpl(session: getIt<SessionService>()),
  );
  getIt.registerFactory<ParcelaProvider>(
        () => ParcelaProvider(repository: getIt<ParcelaRepository>()),
  );
}
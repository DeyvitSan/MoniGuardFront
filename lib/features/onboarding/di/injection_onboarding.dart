import 'package:get_it/get_it.dart';

import '../data/repositories/local_storage_service_impl.dart';
import '../domain/local_storage_service.dart';

void initOnboardingDependencies(GetIt getIt) {
  getIt.registerLazySingleton<LocalStorageService>(
        () => LocalStorageServiceImpl(),
  );
}
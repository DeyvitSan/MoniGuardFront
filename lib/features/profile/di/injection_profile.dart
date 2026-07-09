import 'package:get_it/get_it.dart';

import '../data/repositories/profile_repository_impl.dart';
import '../domain/profile_repository.dart';
import '../presentation/provider/profile_provider.dart';

void initProfileDependencies(GetIt getIt) {
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl());
  getIt.registerFactory<ProfileProvider>(
    () => ProfileProvider(repository: getIt<ProfileRepository>()),
  );
}

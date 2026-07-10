import 'package:get_it/get_it.dart';

import '../data/repositories/dashboard_repository_impl.dart';
import '../domain/dashboard_repository.dart';
import '../presentation/provider/home_provider.dart';

void initHomeDependencies(GetIt getIt) {
  getIt.registerLazySingleton<DashboardRepository>(
        () => DashboardRepositoryImpl(),
  );
  getIt.registerFactory<HomeProvider>(
        () => HomeProvider(repository: getIt<DashboardRepository>()),
  );
}
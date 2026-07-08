import 'package:get_it/get_it.dart';

import '../data/repositories/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../presentation/provider/login_provider.dart';
import '../presentation/provider/register_provider.dart';

void initAuthDependencies(GetIt getIt) {
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(),
  );
  getIt.registerFactory<LoginProvider>(
        () => LoginProvider(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<RegisterProvider>(
        () => RegisterProvider(authRepository: getIt<AuthRepository>()),
  );
}
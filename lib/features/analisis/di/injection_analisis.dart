import 'package:get_it/get_it.dart';

import '../../home/domain/dashboard_repository.dart';
import '../presentation/provider/analisis_provider.dart';

void initAnalisisDependencies(GetIt getIt) {
  getIt.registerFactory<AnalisisProvider>(
        () => AnalisisProvider(repository: getIt<DashboardRepository>()),
  );
}
import 'package:get_it/get_it.dart';
import 'data/alarm_local_datasource.dart';
import 'data/alarm_repository.dart';
import 'data/alarm_repository_impl.dart';
import 'presentation/cubit/alarm_cubit.dart';

final getIt = GetIt.instance;

void setupAlarmDependencies() {
  // Data Sources
  getIt.registerLazySingleton<AlarmLocalDataSource>(
    () => AlarmLocalDataSource(),
  );

  // Repositories
  getIt.registerLazySingleton<AlarmRepository>(
    () => AlarmRepositoryImpl(getIt<AlarmLocalDataSource>()),
  );

  // Cubits
  getIt.registerFactory<AlarmCubit>(() => AlarmCubit(getIt<AlarmRepository>()));
}

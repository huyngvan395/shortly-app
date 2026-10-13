// di/injector.dart

import 'package:get_it/get_it.dart';



import '../core/notifier/auth_notifier.dart';
import '../core/services/cloudinary/cloudinary_service.dart';
import '../core/theme/theme_provider.dart';

import '../features/auth/data/datasources/auth_remote_datasources.dart';

import '../features/auth/data/repositories/auth_repositories_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';

import '../features/profile/data/datasources/profile_remote_datasource.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';

final sl = GetIt.instance;

Future<void> setupInjector() async {
  sl.registerLazySingleton(() => ThemeProvider());
  sl.registerLazySingleton(() => AuthNotifier());
  sl.registerLazySingleton(() => CloudinaryService());

  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // Profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(remote: sl()),
  );
}

// di/injector.dart

import 'package:get_it/get_it.dart';

// Core
import '../core/services/cloudinary/cloudinary_service.dart';

// Auth
import '../features/auth/data/datasources/auth_remote_datasources.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';

// Profile
import '../features/profile/data/datasources/profile_remote_datasource.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';

final sl = GetIt.instance;

Future<void> setupInjector() async {
  // ============================================================
  // Cloudinary - ISSUE #9
  // ============================================================

  sl.registerLazySingleton(() => CloudinaryService());

  // ============================================================
  // Auth - ISSUE #7
  // ============================================================

  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));

  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // ============================================================
  // Profile - ISSUE #9
  // ============================================================

  sl.registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
}
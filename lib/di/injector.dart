// di/injector.dart

import 'package:get_it/get_it.dart';
import 'package:shortly_app/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:shortly_app/features/video/data/datasources/video_remote_datasource.dart';
import 'package:shortly_app/features/video/data/repositories/video_repository_impl.dart';
import 'package:shortly_app/features/video/domain/repositories/video_repository.dart';
import 'package:shortly_app/features/video/domain/usecases/video_usecases.dart';



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

  sl.registerLazySingleton<VideoRemoteDataSource>(
        () => VideoRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<VideoRepository>(
        () => VideoRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetForYouFeedUseCase(sl()));
  sl.registerLazySingleton(() => GetFollowingFeedUseCase(sl()));
  sl.registerLazySingleton(() => GetUserVideosUseCase(sl()));
  sl.registerLazySingleton(() => GetVideoByIdUseCase(sl()));
  sl.registerLazySingleton(() => ToggleVideoLikeUseCase(sl()));
  sl.registerLazySingleton(() => IncrementVideoViewUseCase(sl()));
  sl.registerLazySingleton(() => CreateVideoUseCase(sl()));
  sl.registerLazySingleton(() => DeleteVideoUseCase(sl()));

  sl.registerFactory(
        () => FeedBloc(
      getForYouFeed: sl(),
      getFollowingFeed: sl(),
      toggleVideoLike: sl(),
      incrementView: sl(),
    ),
  );
}

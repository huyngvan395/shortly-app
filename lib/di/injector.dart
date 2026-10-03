// di/injector.dart

import 'package:get_it/get_it.dart';
import 'package:shortly_app/core/theme/theme_provider.dart';

import '../core/services/cloudinary/cloudinary_service.dart';
import '../core/services/media/audio_recorder_service.dart';
import '../core/services/media/image_picker_service.dart';
import '../core/services/supabase/presence_service.dart';

final sl = GetIt.instance;

Future<void> setupInjector() async {
  sl.registerLazySingleton(() => ThemeProvider());
}

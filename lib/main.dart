import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shortly_app/app.dart';
import 'package:shortly_app/core/services/supabase/index.dart';
import 'package:shortly_app/di/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseService.initialize();
  await setupInjector();
  runApp(App());
}

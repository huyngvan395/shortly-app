import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shortly_app/admin_app.dart';
import 'package:shortly_app/core/services/supabase/index.dart';
import 'package:shortly_app/di/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // Clean URL strategy without '#' for premium web feeling
  await dotenv.load(fileName: '.env');
  await SupabaseService.initialize();
  await setupInjector();
  runApp(const AdminApp());
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shortly_app/routes/app_router.dart';

import 'core/layout/app_shell.dart';

class App extends StatefulWidget {

  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.router();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: MaterialApp.router(
        title: 'Shareco',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        routerConfig: _router,
      ),
    );
  }
}

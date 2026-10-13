
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shortly_app/features/profile/presentation/screen/profile_screen.dart';

import '../features/auth/presentation/sceen/auth_callback_screen.dart';

class Routes {
static const login = "/login";
static const register = "/register";
static const profile = "/profile";
static const profileDetail = "/profile/:id";

static String profileOf(String id) => "$profile/$id";
}

class AppRouter {
static GoRouter router() => GoRouter(
initialLocation: Routes.login,
routes: [
GoRoute(
path: '/login-callback',
builder: (_, state) => AuthCallbackScreen(uri: state.uri),
),
GoRoute(
path: Routes.profile,
builder: (_, _) => const SizedBox.shrink(),
),
GoRoute(
path: Routes.profileDetail,
builder: (_, state) {
final uid = state.pathParameters['id'] ?? '';
return ProfileScreen(userId: uid);
},
),
],
);
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shortly_app/di/injector.dart';
import 'package:shortly_app/features/feed/presentation/bloc/search_bloc.dart';
import 'package:shortly_app/features/feed/presentation/screen/search_screen.dart';
import 'package:shortly_app/features/profile/presentation/screen/profile_screen.dart';
import 'package:shortly_app/features/video/domain/repositories/video_repository.dart';
import 'package:shortly_app/features/chat/domain/entities/chat_entities.dart';
import 'package:shortly_app/features/chat/presentation/screen/chat_screen.dart';
import 'package:shortly_app/features/chat/presentation/screen/message_screen.dart';

import '../features/auth/presentation/sceen/auth_callback_screen.dart';
import '../features/ecommerce/shop/presentation/screen/shop_profile_screen.dart';
import '../features/ecommerce/shop/presentation/screen/seller_registration_screen.dart';

import '../features/ecommerce/review/presentation/screen/review_form_screen.dart';
import '../features/ecommerce/order/presentation/screen/order_detail_screen.dart';

class Routes {
  static const login = "/login";
  static const register = "/register";
  static const feed = "/feed";
  static const searchFeed = "/search-feed";
  static const searchFeedViewer = "/search-feed-viewer";
  static const profile = "/profile";
  static const profileDetail = "/profile/:id";

  static String profileOf(String id) => "$profile/$id";

  static const chat = "/chat";
  static const messages = "/messages";

  static const shopProfile = "/shop/:id";
  static const registerSeller = "/register-seller";
  static const reviewForm = "/review/new";
  static const orderDetail = "/orders/:id";
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
        path: Routes.chat,
        builder: (_, _) => const ChatScreen(),
      ),
      GoRoute(
        path: Routes.messages,
        builder: (_, state) {
          final conversation = state.extra;
          return MessageScreen(
            conversation: conversation as ConversationEntity,
          );
        },
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
      GoRoute(
        path: Routes.shopProfile,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return ShopProfileScreen(shopId: id);
        },
      ),
      GoRoute(
        path: Routes.registerSeller,
        builder: (_, _) => const SellerRegistrationScreen(),
      ),
      GoRoute(
        path: Routes.reviewForm,
        builder: (_, state) {
          final item = state.extra;
          if (item == null) return const SizedBox.shrink();
          return ReviewFormScreen(orderItem: item as dynamic);
        },
      ),
      GoRoute(
        path: Routes.orderDetail,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: Routes.searchFeed,
        builder: (context, _) {
          return BlocProvider(
            create: (_) => SearchBloc(
              videoRepository: sl<VideoRepository>(),
            ),
            child: const SearchScreen(),
          );
        },
      ),
    ],
  );
}
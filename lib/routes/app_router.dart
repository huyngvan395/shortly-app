import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/navigation/app_route_observer.dart';


class Routes {
  static const login = "/login";
  static const register = "/register";
  static const feed = "/feed";
  static const searchFeed = "/search-feed";
  static const searchFeedViewer = "/search-feed-viewer";
  static const profile = "/profile";
  static const profileDetail = "/profile/:id";

  static String profileOf(String id) => "$profile/$id";
  static const video = "/video";
  static const post = "/post";
  static const chat = "/chat";
  static const create = "/create";
  static const discover = "/discover";
  static const messages = "/messages";
  static const ecommerce = "/ecommerce";
  static const productDetail = "/products/:id";
  static const cart = "/cart";
  static const checkout = "/checkout";
  static const orders = "/orders";
  static const orderDetail = "/orders/:id";
  static const addresses = "/addresses";
  static const addressCreate = "/addresses/new";
  static const addressEdit = "/addresses/:id/edit";
  static const shopProfile = "/shop/:id";
  static const reviewForm = "/review/new";
  static const registerSeller = "/register-seller";
}

class AppRouter {
  static GoRouter router() => GoRouter(
    observers: [routeObserver],
    initialLocation: Routes.feed,
    routes: [

    ],
  );
}

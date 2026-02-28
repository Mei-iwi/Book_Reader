import 'package:book_reader/presentation/pages/auth/Login.dart';
import 'package:book_reader/presentation/pages/splash/splash_page.dart';
import 'package:flutter/material.dart';

class AppRoute {
  static const splash = '/';
  static const login = '/login';
  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => SplashPage(),
    login: (_) => Login(),
  };
}

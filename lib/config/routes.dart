import 'package:book_reader/presentation/pages/auth/ForgotPassword.dart';
import 'package:book_reader/presentation/pages/auth/Login.dart';
import 'package:book_reader/presentation/pages/auth/NewPassword.dart';
import 'package:book_reader/presentation/pages/auth/SignIn.dart';
import 'package:book_reader/presentation/pages/auth/SignUp.dart';
import 'package:book_reader/presentation/pages/auth/VerifyInfo.dart';
import 'package:book_reader/presentation/pages/splash/splash_page.dart';
import 'package:flutter/material.dart';

class AppRoute {
  static const splash = '/';
  static const login = '/login';
  static const signin = '/signin';
  static const signup = '/signup';
  static const fotgotpassword = '/forgotpassword';
  static const verify = '/verify';
  static const newpassword = '/newpassword';
  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashPage(),
    login: (_) => const Login(),
    signin: (_) => const Signin(),
    signup: (_) => const Signup(),
    fotgotpassword: (_) => const Forgotpassword(),
    verify: (_) => const Verifyinfo(),
    newpassword: (_) => const NewPassword(),
  };
}

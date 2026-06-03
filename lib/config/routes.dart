import 'package:book_reader/presentation/pages/auth/forgot_password.dart';
import 'package:book_reader/presentation/pages/auth/login.dart';
import 'package:book_reader/presentation/pages/auth/new_password.dart';
import 'package:book_reader/presentation/pages/auth/sign_in.dart';
import 'package:book_reader/presentation/pages/auth/sign_up.dart';
import 'package:book_reader/presentation/pages/auth/verify_info.dart';
import 'package:book_reader/presentation/pages/book_detail/book_detail_page.dart';
import 'package:book_reader/presentation/pages/home/homescreen.dart';
import 'package:book_reader/presentation/pages/membership/membership_package_page.dart';
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
  static const home = '/homescreen';
  static const membership = '/membership';
  static const bookDetail = '/book-detail';
  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashPage(),
    login: (_) => const Login(),
    signin: (_) => const Signin(),
    signup: (_) => const Signup(),
    fotgotpassword: (_) => const Forgotpassword(),
    verify: (_) => const Verifyinfo(),
    newpassword: (_) => const NewPassword(),
    home: (_) => Homescreen(),
    membership: (_) => const MembershipPackageScreen(),
    bookDetail: (_) => const BookDetailPage(),
  };
}

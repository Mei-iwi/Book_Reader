import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme/app_theme.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoute.splash,
      routes: AppRoute.routes,
    );
  }
}

import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/my_images.dart';
import 'package:book_reader/core/constants/my_text.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/button_style.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/signup_other.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/ShareWidgetAuth/banner.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _Login();
}

class _Login extends State<Login> {
  Future<void> _loginWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithGoogle();

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoute.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Google login failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          myBanner(urlBanner: Myimages.myBanner, text: Mytext.chooseLogin),
          SizedBox(height: 70),
          button(
            text: 'Sign in',
            func: () {
              Navigator.pushReplacementNamed(context, AppRoute.signin);
            },
          ),
          SizedBox(height: 25),
          buttonFull(
            text: 'Sign up',
            func: () {
              Navigator.pushReplacementNamed(context, AppRoute.signup);
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: BottomAppBar(
          color: theme.colorScheme.surface,
          height: 100,
          child: Column(
            children: [
              Text(
                isLoading ? "Signing in..." : "or Sign up with",
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  signUpOther(
                    Myimages.iconGoogle,
                    isLoading ? () {} : _loginWithGoogle,
                  ),
                  SizedBox(width: 10),
                  signUpOther(Myimages.iconFaceBook, () {}),
                  SizedBox(width: 10),
                  signUpOther(Myimages.iconInstagram, () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

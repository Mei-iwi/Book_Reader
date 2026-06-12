import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/my_images.dart';
import 'package:book_reader/core/constants/my_text.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/auth_scroll_view.dart';
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
          content: Text(authProvider.errorMessage ?? 'Đăng nhập Google thất bại'),
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
      body: AuthScrollView(
        child: Column(
          children: [
            myBanner(urlBanner: Myimages.myBanner, text: Mytext.chooseLogin),
            SizedBox(height: 44),
            button(
              text: 'Đăng nhập',
              func: () {
                Navigator.pushReplacementNamed(context, AppRoute.signin);
              },
            ),
            SizedBox(height: 20),
            buttonFull(
              text: 'Đăng ký',
              func: () {
                Navigator.pushReplacementNamed(context, AppRoute.signup);
              },
            ),
            SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoute.adminLogin);
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Đăng nhập quản trị'),
            ),
            SizedBox(height: 28),
            Text(
              isLoading ? "Đang đăng nhập..." : "hoặc đăng nhập bằng",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                signUpOther(
                  Myimages.iconGoogle,
                  isLoading ? () {} : _loginWithGoogle,
                ),
                signUpOther(Myimages.iconFaceBook, () {}),
                signUpOther(Myimages.iconInstagram, () {}),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

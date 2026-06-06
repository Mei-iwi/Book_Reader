import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/my_images.dart';
import 'package:book_reader/core/constants/my_text.dart';
import 'package:book_reader/core/utils/validators.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/banner.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/button_style.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/form.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<StatefulWidget> createState() => _Signin();
}

class _Signin extends State<Signin> {
  final _formKey = GlobalKey<FormState>();
  final mail = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    mail.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: mail.text.trim(),
      password: password.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoute.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            myBanner(urlBanner: Myimages.myBanner, text: Mytext.textSignIn),
            const SizedBox(height: 70),
            FormInput(
              text: 'Phone or Email',
              icon: Icons.mail,
              isPassword: false,
              controller: mail,
              validator: AppValidators.emailOrPhone,
            ),
            const SizedBox(height: 30),
            FormInput(
              text: 'Password',
              icon: Icons.lock,
              isPassword: true,
              controller: password,
              validator: AppValidators.password,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoute.fotgotpassword,
                      );
                    },
                    child: const Text(
                      'Forget Password',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (isLoading)
              const CircularProgressIndicator()
            else
              buttonFull(text: Mytext.textSignIn, func: _login),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have a account?",
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoute.signup);
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

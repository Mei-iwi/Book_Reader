import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/my_images.dart';
import 'package:book_reader/core/constants/my_text.dart';
import 'package:book_reader/core/utils/validators.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/auth_scroll_view.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/banner.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/button_style.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/form.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<StatefulWidget> createState() => _Signup();
}

class _Signup extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final fullName = TextEditingController();
  final mail = TextEditingController();
  final passWord = TextEditingController();
  final confirmPassword = TextEditingController();

  @override
  void dispose() {
    fullName.dispose();
    mail.dispose();
    passWord.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      fullName: fullName.text.trim(),
      email: mail.text.trim(),
      password: passWord.text,
      confirmPassword: confirmPassword.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoute.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Register failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              myBanner(urlBanner: Myimages.myBanner, text: Mytext.textSignUp),
              const SizedBox(height: 24),
              FormInput(
                text: 'Full name',
                icon: Icons.people_alt,
                isPassword: false,
                controller: fullName,
                validator: (v) =>
                    AppValidators.requiredText(v, 'ho ten') ??
                    AppValidators.maxLength(v, 80, 'Ho ten'),
              ),
              const SizedBox(height: 22),
              FormInput(
                text: 'Phone or Email',
                icon: Icons.mail,
                isPassword: false,
                controller: mail,
                validator: AppValidators.email,
              ),
              const SizedBox(height: 22),
              FormInput(
                text: 'Password',
                icon: Icons.lock,
                isPassword: true,
                controller: passWord,
                validator: AppValidators.password,
              ),
              const SizedBox(height: 22),
              FormInput(
                text: 'Confirm Password',
                icon: Icons.lock,
                isPassword: true,
                controller: confirmPassword,
                validator: (v) =>
                    AppValidators.confirmPassword(v, passWord.text),
              ),
              const SizedBox(height: 24),
              if (isLoading)
                const CircularProgressIndicator()
              else
                buttonFull(text: Mytext.textSignUp, func: _register),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Already have a account?',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoute.signin);
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/myImages.dart';
import 'package:book_reader/core/constants/myText.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/banner.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/buttonStyle.dart';
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              myBanner(urlBanner: Myimages.myBanner, text: Mytext.textSignUp),
              const SizedBox(height: 30),
              formInput(
                text: 'Full name',
                icon: Icons.people_alt,
                isPassword: false,
                controller: fullName,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui long nhap ho ten';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              formInput(
                text: 'Phone or Email',
                icon: Icons.lock,
                isPassword: false,
                controller: mail,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui long nhap email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              formInput(
                text: 'Password',
                icon: Icons.lock,
                isPassword: true,
                controller: passWord,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui long nhap mat khau';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              formInput(
                text: 'Confirm Password',
                icon: Icons.lock,
                isPassword: true,
                controller: confirmPassword,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui long nhap lai mat khau';
                  }
                  if (v != passWord.text.trim()) {
                    return 'Mat khau nhap lai khong dung';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              if (isLoading)
                const CircularProgressIndicator()
              else
                buttonFull(text: Mytext.textSignUp, func: _register),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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

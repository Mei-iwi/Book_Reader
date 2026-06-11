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

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<StatefulWidget> createState() => _NewPassword();
}

class _NewPassword extends State<NewPassword> {
  final _formKey = GlobalKey<FormState>();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  Map<String, String> get _resetArguments {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map) {
      return {
        'email': arguments['email']?.toString() ?? '',
        'code': arguments['code']?.toString() ?? '',
      };
    }
    return {'email': '', 'code': ''};
  }

  Future<void> _submitNewPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final arguments = _resetArguments;
    final email = arguments['email'] ?? '';
    final code = arguments['code'] ?? '';
    if (email.isEmpty || code.isEmpty) {
      _showMessage('Thong tin xac thuc khong hop le. Vui long thuc hien lai.');
      Navigator.pushReplacementNamed(context, AppRoute.fotgotpassword);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      email: email,
      code: code,
      password: newPassword.text,
      confirmPassword: confirmPassword.text,
    );
    if (!mounted) return;

    if (!success) {
      _showMessage(authProvider.errorMessage ?? 'Khong the cap nhat mat khau');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Thanh cong",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Mat khau cua ban da duoc cap nhat. Vui long dang nhap lai.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoute.signin);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            myBanner(urlBanner: Myimages.myBanner, text: Mytext.newPassword),
            SizedBox(height: 70),
            FormInput(
              text: "Enter your new Password",
              icon: Icons.lock,
              isPassword: true,
              controller: newPassword,
              validator: AppValidators.password,
            ),
            SizedBox(height: 30),
            FormInput(
              text: "Confirm password",
              icon: Icons.lock,
              isPassword: true,
              controller: confirmPassword,
              validator: (v) =>
                  AppValidators.confirmPassword(v, newPassword.text),
            ),
            SizedBox(height: 50),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isLoading) {
                  return CircularProgressIndicator();
                }

                return buttonFull(text: 'Submit', func: _submitNewPassword);
              },
            ),
          ],
        ),
      ),
    );
  }
}

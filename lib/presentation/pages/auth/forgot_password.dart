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

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<StatefulWidget> createState() => _Forgotpassword();
}

class _Forgotpassword extends State<Forgotpassword> {
  final _formKey = GlobalKey<FormState>();
  final mail = TextEditingController();

  Future<void> _sendResetCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = mail.text.trim();
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.requestPasswordReset(email: email);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ma xac thuc da duoc gui den $email')),
      );
      Navigator.pushReplacementNamed(
        context,
        AppRoute.verify,
        arguments: email,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authProvider.errorMessage ?? 'Khong the gui ma xac thuc'),
      ),
    );
  }

  @override
  void dispose() {
    mail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            myBanner(urlBanner: Myimages.myBanner, text: Mytext.forgotPassword),
            SizedBox(height: 70),
            FormInput(
              text: "Enter your registered Email",
              icon: Icons.mail,
              isPassword: false,
              controller: mail,
              validator: AppValidators.email,
            ),
            SizedBox(height: 50),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isLoading) {
                  return CircularProgressIndicator();
                }

                return buttonFull(text: 'Send', func: _sendResetCode);
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoute.signin);
                  },
                  child: Text(
                    "Back to Sign in",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            button(
              text: 'Sign Up',
              func: () {
                Navigator.pushReplacementNamed(context, AppRoute.signup);
              },
            ),
          ],
        ),
      ),
    );
  }
}

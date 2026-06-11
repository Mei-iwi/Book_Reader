import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/my_images.dart';
import 'package:book_reader/core/constants/my_text.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/banner.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/button_style.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/form.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Verifyinfo extends StatefulWidget {
  const Verifyinfo({super.key});

  @override
  State<StatefulWidget> createState() => _Verifyinfo();
}

class _Verifyinfo extends State<Verifyinfo> {
  final _formKey = GlobalKey<FormState>();
  final verify = TextEditingController();

  String get _email {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return arguments is String ? arguments : '';
  }

  Future<void> _verifyCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _email;
    if (email.isEmpty) {
      _showMessage('Khong tim thay email. Vui long thuc hien lai.');
      Navigator.pushReplacementNamed(context, AppRoute.fotgotpassword);
      return;
    }

    final code = verify.text.trim();
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyPasswordResetCode(
      email: email,
      code: code,
    );
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(
        context,
        AppRoute.newpassword,
        arguments: {'email': email, 'code': code},
      );
      return;
    }

    _showMessage(authProvider.errorMessage ?? 'Ma xac thuc khong hop le');
  }

  Future<void> _resendCode() async {
    final email = _email;
    if (email.isEmpty) {
      _showMessage('Khong tim thay email. Vui long thuc hien lai.');
      Navigator.pushReplacementNamed(context, AppRoute.fotgotpassword);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.requestPasswordReset(email: email);
    if (!mounted) return;

    _showMessage(
      success
          ? 'Ma xac thuc moi da duoc gui'
          : authProvider.errorMessage ?? 'Khong the gui lai ma xac thuc',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    verify.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            myBanner(urlBanner: Myimages.myBanner, text: Mytext.vertification),
            SizedBox(height: 70),
            FormInput(
              text: "Enter Verification code",
              icon: Icons.key,
              isPassword: false,
              controller: verify,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Vui long nhap ma xac thuc";
                }
                if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) {
                  return "Ma xac thuc gom 6 so";
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "If you didn't receive the code!",
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: _resendCode,
                  child: Text("Resend", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            SizedBox(height: 30),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isLoading) {
                  return CircularProgressIndicator();
                }

                return buttonFull(text: 'Verify', func: _verifyCode);
              },
            ),
          ],
        ),
      ),
    );
  }
}

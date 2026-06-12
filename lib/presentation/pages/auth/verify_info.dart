import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/my_images.dart';
import 'package:book_reader/core/constants/my_text.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/auth_scroll_view.dart';
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
      _showMessage('Không tìm thấy email. Vui lòng thực hiện lại.');
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

    _showMessage(authProvider.errorMessage ?? 'Mã xác thực không hợp lệ');
  }

  Future<void> _resendCode() async {
    final email = _email;
    if (email.isEmpty) {
      _showMessage('Không tìm thấy email. Vui lòng thực hiện lại.');
      Navigator.pushReplacementNamed(context, AppRoute.fotgotpassword);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.requestPasswordReset(email: email);
    if (!mounted) return;

    _showMessage(
      success
          ? 'Mã xác thực mới đã được gửi'
          : authProvider.errorMessage ?? 'Không thể gửi lại mã xác thực',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    verify.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              myBanner(urlBanner: Myimages.myBanner, text: Mytext.verification),
              SizedBox(height: 44),
              FormInput(
                text: "Nhập mã xác thực",
                icon: Icons.key,
                isPassword: false,
                controller: verify,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Vui lòng nhập mã xác thực";
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) {
                    return "Mã xác thực gồm 6 số";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
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
              SizedBox(height: 24),
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
      ),
    );
  }
}

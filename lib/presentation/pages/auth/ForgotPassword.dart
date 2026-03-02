import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/myImages.dart';
import 'package:book_reader/core/constants/myText.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/buttonStyle.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/form.dart';
import 'package:flutter/material.dart';
import 'ShareWidget/banner.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<StatefulWidget> createState() => _Forgotpassword();
}

class _Forgotpassword extends State<Forgotpassword> {
  final _formKey = GlobalKey<FormState>();
  final mail = TextEditingController();

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
            formInput(
              text: "Enter your phone or Email",
              icon: Icons.mail,
              isPassword: false,
              controller: mail,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Vui lòng nhập Số điện thoại hoặc email đã đăng ký";
                }
                return null;
              },
            ),
            SizedBox(height: 50),
            buttonFull(
              text: 'Send',
              func: () {
                if (_formKey.currentState?.validate() ?? false) {
                  //Xử lý xác thực email
                  Navigator.pushReplacementNamed(context, AppRoute.verify);
                }
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

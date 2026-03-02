import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/myImages.dart';
import 'package:book_reader/core/constants/myText.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/buttonStyle.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/form.dart';
import 'package:flutter/material.dart';
import 'ShareWidget/banner.dart';

class Verifyinfo extends StatefulWidget {
  const Verifyinfo({super.key});

  @override
  State<StatefulWidget> createState() => _Verifyinfo();
}

class _Verifyinfo extends State<Verifyinfo> {
  final _formKey = GlobalKey<FormState>();
  final verify = TextEditingController();

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
            formInput(
              text: "Enter Verification code",
              icon: Icons.key,
              isPassword: false,
              controller: verify,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Vui lòng nhập mã xác thực";
                }
                //Xử lý trường hợp mã không chính xác
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
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoute.signin);
                  },
                  child: Text("Resend", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            SizedBox(height: 30),
            buttonFull(
              text: 'Verify',
              func: () {
                if (_formKey.currentState?.validate() ?? false) {
                  //Xử lý xác thực mã
                  Navigator.pushReplacementNamed(context, AppRoute.newpassword);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

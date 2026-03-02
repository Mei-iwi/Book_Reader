import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/myImages.dart';
import 'package:book_reader/core/constants/myText.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/buttonStyle.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/form.dart';
import 'package:flutter/material.dart';
import 'ShareWidget/banner.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            myBanner(urlBanner: Myimages.myBanner, text: Mytext.textSignIn),
            SizedBox(height: 70),
            formInput(
              text: "Phone or Email",
              icon: Icons.mail,
              isPassword: false,
              controller: mail,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Điện thoại hoặc email không được để trống";
                }
                return null;
              },
            ),
            SizedBox(height: 30),
            formInput(
              text: "Password",
              icon: Icons.lock,
              isPassword: true,
              controller: password,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Mật khẩu không được để trống";
                }
                return null;
              },
            ),
            Padding(
              padding: EdgeInsets.only(right: 80),
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
                    child: Text(
                      'Forget Password',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            buttonFull(
              text: Mytext.textSignIn,
              func: () {
                if (_formKey.currentState?.validate() ?? false) {
                  //Xử lý chuyển hướng
                }
              },
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have a account?",
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoute.signup);
                  },
                  child: Text("Sign up", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

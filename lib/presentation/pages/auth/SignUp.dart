import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/myImages.dart';
import 'package:book_reader/core/constants/myText.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/buttonStyle.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/form.dart';
import 'package:flutter/material.dart';
import 'ShareWidget/banner.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              myBanner(urlBanner: Myimages.myBanner, text: Mytext.textSignUp),
              SizedBox(height: 30),
              formInput(
                text: "Full name",
                icon: Icons.people_alt,
                isPassword: false,
                controller: fullName,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Vui lòng nhập đầy đủ họ và tên";
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              formInput(
                text: "Phone or Email",
                icon: Icons.lock,
                isPassword: false,
                controller: mail,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Vui lòng nhập Số điện thoại hoặc Email";
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              formInput(
                text: "Password",
                icon: Icons.lock,
                isPassword: true,
                controller: passWord,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Vui lòng nhập mật khẩu";
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              formInput(
                text: "Confirm Password",
                icon: Icons.lock,
                isPassword: true,
                controller: confirmPassword,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Vui lòng nhập lại mật khẩu";
                  }
                  if (v == confirmPassword.text.trim()) {
                    return "Mật khẩu nhập lại không đúng";
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              buttonFull(
                text: Mytext.textSignUp,
                func: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    //Xử lý tạo tài khoản
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have a account?",
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoute.signin);
                    },
                    child: Text(
                      "Sign in",
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

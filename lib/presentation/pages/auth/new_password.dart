import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/my_images.dart';
import 'package:book_reader/core/constants/my_text.dart';
import 'package:book_reader/core/utils/validators.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/button_style.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/form.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/ShareWidgetAuth/banner.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<StatefulWidget> createState() => _NewPassword();
}

class _NewPassword extends State<NewPassword> {
  final _formKey = GlobalKey<FormState>();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

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
            buttonFull(
              text: 'Submit',
              func: () {
                if (_formKey.currentState?.validate() ?? false) {
                  //Xử lý cập nhật mật khẩu
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        "Thành công",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      content: Text(
                        "Mật khẩu của bạn đã được cập nhật vui lòng đăng nhập lại",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoute.signin,
                            );
                          },
                          child: Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

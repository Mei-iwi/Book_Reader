import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/myImages.dart';
import 'package:book_reader/core/constants/myText.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/buttonStyle.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/form.dart';
import 'package:flutter/material.dart';
import 'ShareWidget/banner.dart';

class NewPassword extends StatelessWidget {
  const NewPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          myBanner(urlBanner: Myimages.myBanner, text: Mytext.newPassword),
          SizedBox(height: 70),
          formInput(
            text: "Enter your new Password",
            icon: Icons.lock,
            isPassword: true,
          ),
          SizedBox(height: 30),
          formInput(
            text: "Confirm password",
            icon: Icons.lock,
            isPassword: true,
          ),
          SizedBox(height: 50),
          buttonFull(
            text: 'Submit',
            func: () {
              Navigator.pushReplacementNamed(context, AppRoute.signin);
            },
          ),
        ],
      ),
    );
  }
}

import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/myImages.dart';
import 'package:book_reader/core/constants/myText.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/buttonStyle.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/form.dart';
import 'package:flutter/material.dart';
import 'ShareWidget/banner.dart';

class Forgotpassword extends StatelessWidget {
  const Forgotpassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          myBanner(urlBanner: Myimages.myBanner, text: Mytext.forgotPassword),
          SizedBox(height: 70),
          const formInput(
            text: "Enter your phone or Email",
            icon: Icons.mail,
            isPassword: false,
          ),
          SizedBox(height: 50),
          buttonFull(
            text: 'Send',
            func: () {
              Navigator.pushReplacementNamed(context, AppRoute.verify);
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
    );
  }
}

import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/myImages.dart';
import 'package:book_reader/core/constants/myText.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/SigupOther.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/buttonStyle.dart';
import 'package:flutter/material.dart';
import 'ShareWidget/banner.dart';

class Login extends StatelessWidget {
  const Login({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          myBanner(urlBanner: Myimages.myBanner, text: Mytext.chooseLogin),
          SizedBox(height: 70),
          button(
            text: 'Sign in',
            func: () {
              Navigator.pushReplacementNamed(context, AppRoute.signin);
            },
          ),
          SizedBox(height: 25),
          buttonFull(
            text: 'Sign up',
            func: () {
              Navigator.pushReplacementNamed(context, AppRoute.signup);
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 30),

        child: BottomAppBar(
          color: Colors.white,
          height: 100,
          child: Column(
            children: [
              Text(
                "or Sign up with",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  signUpOther(Myimages.iconGoogle, () {}),
                  SizedBox(width: 10),
                  signUpOther(Myimages.iconFaceBook, () {}),
                  SizedBox(width: 10),
                  signUpOther(Myimages.iconInstagram, () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

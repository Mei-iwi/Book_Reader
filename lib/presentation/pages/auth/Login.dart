import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/myImages.dart';
import 'package:book_reader/core/constants/myText.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/SigupOther.dart';
import 'package:book_reader/core/widgets/ShareWidgetAuth/buttonStyle.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/ShareWidgetAuth/banner.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _Login();
}

class _Login extends State<Login> {
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

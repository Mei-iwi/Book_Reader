import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/myImages.dart';
import 'package:book_reader/core/constants/myText.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/buttonStyle.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/form.dart';
import 'package:flutter/material.dart';
import 'ShareWidget/banner.dart';

class Signin extends StatelessWidget {
  const Signin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          myBanner(urlBanner: Myimages.myBanner, text: Mytext.textSignIn),
          SizedBox(height: 70),
          formInput(
            text: "Phone or Email",
            icon: Icons.mail,
            isPassword: false,
          ),
          SizedBox(height: 30),
          formInput(text: "Password", icon: Icons.lock, isPassword: true),
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
          buttonFull(text: Mytext.textSignIn, func: () {}),
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
    );
  }
}

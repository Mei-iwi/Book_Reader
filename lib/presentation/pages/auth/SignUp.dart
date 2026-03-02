import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/myImages.dart';
import 'package:book_reader/core/constants/myText.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/buttonStyle.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/form.dart';
import 'package:flutter/material.dart';
import 'ShareWidget/banner.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          myBanner(urlBanner: Myimages.myBanner, text: Mytext.textSignUp),
          SizedBox(height: 30),
          const formInput(
            text: "Full name",
            icon: Icons.people_alt,
            isPassword: false,
          ),
          SizedBox(height: 30),
          const formInput(
            text: "Phone or Email",
            icon: Icons.lock,
            isPassword: false,
          ),
          SizedBox(height: 30),
          const formInput(text: "Password", icon: Icons.lock, isPassword: true),
          SizedBox(height: 30),
          const formInput(
            text: "Confirm Password",
            icon: Icons.lock,
            isPassword: true,
          ),
          SizedBox(height: 30),
          buttonFull(text: Mytext.textSignUp, func: () {}),
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
                child: Text("Sign in", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

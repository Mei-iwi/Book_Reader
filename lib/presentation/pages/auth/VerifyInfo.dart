import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/myImages.dart';
import 'package:book_reader/core/constants/myText.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/buttonStyle.dart';
import 'package:book_reader/presentation/pages/auth/ShareWidget/form.dart';
import 'package:flutter/material.dart';
import 'ShareWidget/banner.dart';

class Verifyinfo extends StatelessWidget {
  const Verifyinfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          myBanner(urlBanner: Myimages.myBanner, text: Mytext.vertification),
          SizedBox(height: 70),
          const formInput(
            text: "Enter Verification code",
            icon: Icons.key,
            isPassword: false,
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
              Navigator.pushReplacementNamed(context, AppRoute.newpassword);
            },
          ),
        ],
      ),
    );
  }
}

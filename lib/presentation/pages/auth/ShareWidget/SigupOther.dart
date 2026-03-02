import 'package:flutter/material.dart';

Widget signUpOther(String urlIcon, VoidCallback func) {
  return IconButton(
    onPressed: func,
    icon: Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(urlIcon), fit: BoxFit.cover),
      ),
    ),
  );
}

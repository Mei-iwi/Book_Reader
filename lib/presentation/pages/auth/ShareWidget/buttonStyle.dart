import 'package:flutter/material.dart';

TextStyle stylebutton({
  required double size,
  required bool fontWeight,
  required Color color,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: (fontWeight ? FontWeight.bold : FontWeight.normal),
    color: color,
    fontStyle: FontStyle.italic,
  );
}

Widget button({required String text, required VoidCallback func}) {
  return ElevatedButton(
    onPressed: func,
    style: ElevatedButton.styleFrom(
      minimumSize: Size(300, 55),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.blue, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),

    child: Text(
      text,
      style: stylebutton(size: 20, fontWeight: true, color: Colors.blue),
    ),
  );
}

Widget buttonFull({required String text, required VoidCallback func}) {
  return ElevatedButton(
    onPressed: func,
    style: ElevatedButton.styleFrom(
      minimumSize: Size(300, 55),
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),

    child: Text(
      text,
      style: stylebutton(size: 20, fontWeight: true, color: Colors.white),
    ),
  );
}

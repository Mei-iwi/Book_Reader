import 'package:flutter/material.dart';

Widget myBanner({required String urlBanner, required String text}) {
  return Builder(
    builder: (context) {
      return SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                image: DecorationImage(
                  image: AssetImage(urlBanner),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_horiz, color: Colors.white),
              ),
            ),
            Center(
              child: Text(
                text,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    },
  );
}

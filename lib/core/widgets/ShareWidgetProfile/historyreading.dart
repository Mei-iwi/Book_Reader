import 'package:book_reader/core/widgets/ShareFunction/checkImage.dart';
import 'package:flutter/material.dart';

Widget bookReading({
  required String url,
  required String name,
  required double percent,
}) {
  return Builder(
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {},
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  blurRadius: 10,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: checkSourceImage(urlImage: url)
                          ? AssetImage(url)
                          : NetworkImage(url),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 20),
                    percentBook(percent),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget percentBook(double percent) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(100),
        ),
        width: 250,
        height: 10,
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(100),
        ),
        width: (percent / 100) * 250,
        height: 10,
      ),
      Positioned.fill(
        top: -30,
        child: Center(
          child: Text(
            "$percent% Completed",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    ],
  );
}

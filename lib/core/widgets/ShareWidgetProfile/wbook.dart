import 'package:flutter/material.dart';

Widget wbook({
  required BuildContext context,
  required String url,
  required String title,
  required author,
  required VoidCallback func,
}) {
  return InkWell(
    onTap: () {
      func();
      showBookSnackBar(context, title: title, author: author, url: url);
    },
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: Offset(2, 4),
                  blurRadius: 12,
                ),
              ],
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: _coverImageProvider(url),
              ),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 120,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

bool checkSourceImage({required String urlImage}) {
  final isAsset = urlImage.startsWith('assets/');
  return isAsset ? true : false;
}

ImageProvider _coverImageProvider(String url) {
  final value = url.trim();
  if (value.isEmpty || _isBrokenDemoUrl(value)) {
    return const AssetImage('assets/sample_data/templateImages/chuatenhan.jpg');
  }
  return checkSourceImage(urlImage: value)
      ? AssetImage(value)
      : NetworkImage(value.replaceFirst('http://', 'https://'));
}

bool _isBrokenDemoUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri?.host == 'example.com';
}

void showBookSnackBar(
  BuildContext context, {
  required String title,
  required author,
  required url,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        padding: EdgeInsets.all(0),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.blue, width: 2),
        ),

        duration: const Duration(seconds: 5),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 90,
              height: 100,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    offset: Offset(2, 4),
                    blurRadius: 12,
                  ),
                ],
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: _coverImageProvider(url),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    author,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},

                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(120, 40),

                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      'Read',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(120, 40),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 2, color: Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      'Download',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}

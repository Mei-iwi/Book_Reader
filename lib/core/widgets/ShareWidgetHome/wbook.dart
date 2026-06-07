import 'package:book_reader/core/widgets/ShareFunction/check_image.dart';
import 'package:flutter/material.dart';

Widget wbook({
  required BuildContext context,
  required String url,
  required String title,
  required author,
  required VoidCallback func,
  required VoidCallback onDownload,
  bool isFree = true,
}) {
  return InkWell(
    onTap: () {
      showBookSnackBar(
        context,
        title: title,
        author: author,
        url: url,
        onRead: func,
        onDownload: onDownload,
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 120,
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
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _isBrokenDemoUrl(url)
                    ? Image.asset(
                        'assets/sample_data/templateImages/chuatenhan.jpg',
                        fit: BoxFit.cover,
                      )
                    : checkSourceImage(urlImage: url)
                    ? Image.asset(url, fit: BoxFit.cover)
                    : Image.network(
                        url.replaceFirst('http://', 'https://'),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return Image.asset(
                            'assets/sample_data/templateImages/chuatenhan.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isFree ? 'Miễn phí' : 'Có phí',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isFree ? Colors.green : Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showBookSnackBar(
  BuildContext context, {
  required String title,
  required author,
  required url,
  VoidCallback? onRead,
  VoidCallback? onDownload,
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
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
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
                      title.length > 10
                          ? "${title.substring(0, 10)}..."
                          : title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      author.length > 15
                          ? "${author.substring(0, 15)}..."
                          : author,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: onRead,

                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 40),

                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        'Detail',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: onDownload,
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
      ),
    );
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

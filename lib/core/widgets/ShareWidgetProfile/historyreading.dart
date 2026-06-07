import 'package:book_reader/core/widgets/ShareFunction/check_image.dart';
import 'package:flutter/material.dart';

Widget bookReading({
  required String url,
  required String name,
  required double percent,
  VoidCallback? onTap,
  VoidCallback? onDelete,
}) {
  return Builder(
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onTap,
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
                  width: 72,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _coverImageProvider(url),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),
                      percentBook(percent, context),
                    ],
                  ),
                ),
                if (onDelete != null) ...[
                  SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Xoa tien do doc',
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
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

Widget percentBook(double percent, BuildContext context) {
  final safePercent = percent.clamp(0, 100).toDouble();
  return LayoutBuilder(
    builder: (context, constraints) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(100),
            ),
            width: constraints.maxWidth,
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(100),
            ),
            width: constraints.maxWidth * (safePercent / 100),
            height: 10,
          ),
          Positioned.fill(
            top: -30,
            child: Center(
              child: Text(
                "${safePercent.toStringAsFixed(0)}% Completed",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    },
  );
}

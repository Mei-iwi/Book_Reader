import 'package:book_reader/core/widgets/ShareFunction/check_image.dart';
import 'package:flutter/material.dart';

Widget bookReading({
  required String url,
  required String name,
  required double percent,
  VoidCallback? onTap,
  VoidCallback? onDelete,
  Widget? action,
  int bookmarkCount = 0,
}) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.cardColor,
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
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 20),
                      percentBook(percent, context),
                      if (bookmarkCount > 0) ...[
                        const SizedBox(height: 10),
                        _bookmarkCountChip(bookmarkCount, context),
                      ],
                      if (action != null) ...[SizedBox(height: 12), action],
                    ],
                  ),
                ),
                if (onDelete != null) ...[
                  SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Xóa tiến độ đọc',
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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "${safePercent.toStringAsFixed(0)}% Completed",
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: LinearProgressIndicator(
          minHeight: 10,
          value: safePercent / 100,
          backgroundColor: Colors.blue[100],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    ],
  );
}

Widget _bookmarkCountChip(int count, BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(100),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bookmark,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          '$count bookmark',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    ),
  );
}

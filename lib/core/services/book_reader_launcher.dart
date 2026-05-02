import 'package:book_reader/domain/entities/book.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

class BookReaderLauncher {
  static Future<void> openBook({
    required BuildContext context,
    required Book book,
  }) async {
    // 1. Ưu tiên mở file local nếu đã tải PDF/EPUB thật
    if (book.localFilePath.trim().isNotEmpty) {
      final result = await OpenFilex.open(book.localFilePath);

      if (result.type == ResultType.done) {
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở file: ${result.message}')),
        );
      }

      return;
    }

    // 2. Nếu chưa có file local, mở link đọc online
    final readLink = book.webReaderLink.trim().isNotEmpty
        ? book.webReaderLink.trim()
        : book.previewLink.trim();

    if (readLink.isNotEmpty) {
      final uri = Uri.parse(readLink.replaceFirst('http://', 'https://'));

      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở nội dung đọc online.')),
        );
      }

      return;
    }

    // 3. Không có file, không có link đọc
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sách này chưa có nội dung để đọc.')),
      );
    }
  }
}

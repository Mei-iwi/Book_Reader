import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/usecases/download_book.dart';
import 'package:flutter/foundation.dart';

class HomeBookProvider extends ChangeNotifier {
  final DownloadBook _downloadBook;

  HomeBookProvider({required DownloadBook downloadBook})
    : _downloadBook = downloadBook;
  bool isDownloading = true;
  String? downloadMessage;

  Future<void> downloadSelectedBook(Book book) async {
    try {
      await _downloadBook(book);
      if (book.pdfDownloadLink.isEmpty && book.epubDownloadLink.isEmpty) {
        downloadMessage =
            "Sách này chỉ lưu thông tin offline, chưa có PDF/EPUB";
      } else {
        downloadMessage = "Đã tải sách về thiết bị";
      }
    } catch (e) {
      downloadMessage = "Không thể tải sách. Vui lòng thử lại";
    } finally {
      isDownloading = false;
      notifyListeners();
    }
  }
}

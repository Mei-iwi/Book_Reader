import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/usecases/get_offline_books.dart';
import 'package:flutter/foundation.dart';

class LibraryProvider extends ChangeNotifier {
  final GetOfflineBooks _getOfflineBooks;
  LibraryProvider(this._getOfflineBooks);

  bool isLoading = false;
  String? erroerMessage;
  List<Book> offlineBooks = [];

  Future<void> loadOfflineBook() async {
    try {
      isLoading = true;
      erroerMessage = null;
      notifyListeners();

      offlineBooks = await _getOfflineBooks();
    } catch (e) {
      erroerMessage = "Không thể tải thư viện offline";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

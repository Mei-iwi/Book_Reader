import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:flutter/foundation.dart';

class LibraryProvider extends ChangeNotifier {
  final BookRepository _bookRepository;

  LibraryProvider(this._bookRepository);

  bool isLoading = false;
  String? errMessage;
  List<Book> offlineBooks = [];

  Future<void> loadOfflineBooks() async {
    try {
      isLoading = true;
      errMessage = null;
      notifyListeners();

      offlineBooks = await _bookRepository.getOfflineBooks();

      debugPrint('===== LIBRARY PROVIDER =====');
      debugPrint('Số sách đã lưu: ${offlineBooks.length}');

      for (final book in offlineBooks) {
        debugPrint('Book offline: ${book.title}');
      }
    } catch (e, stackTrace) {
      debugPrint('LOAD OFFLINE BOOKS ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errMessage = 'Không thể tải thư viện offline: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOfflineBook(Book book) async {
    try {
      await _bookRepository.deleteOfflineBooks(book);

      offlineBooks.removeWhere((item) => item.id == book.id);

      notifyListeners();

      debugPrint('===== LIBRARY DELETE SUCCESS =====');
      debugPrint('Deleted book: ${book.title}');
    } catch (e, stackTrace) {
      debugPrint('DELETE OFFLINE BOOK ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errMessage = 'Không thể xóa sách: $e';
      notifyListeners();
    }
  }
}

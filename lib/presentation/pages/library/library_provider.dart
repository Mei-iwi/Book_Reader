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
      debugPrint('Số sách offline nhận được: ${offlineBooks.length}');

      for (final book in offlineBooks) {
        debugPrint('Library book: ${book.title}');
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
}

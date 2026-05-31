import 'package:book_reader/data/datasources/remote/api/library_api.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:flutter/foundation.dart';

class LibraryProvider extends ChangeNotifier {
  final BookRepository _bookRepository;
  final LibraryApi _libraryApi;

  LibraryProvider(this._bookRepository, this._libraryApi);

  bool isLoading = false;
  String? errMessage;
  List<Book> offlineBooks = [];
  List<Book> remoteBooks = [];

  Future<void> loadOfflineBooks() async {
    try {
      isLoading = true;
      errMessage = null;
      notifyListeners();

      try {
        remoteBooks = await _libraryApi.getLibrary(userId: 1);
      } catch (e) {
        debugPrint('LOAD REMOTE LIBRARY ERROR: $e');
        remoteBooks = [];
      }

      final localBooks = await _bookRepository.getOfflineBooks();
      offlineBooks = remoteBooks.isNotEmpty ? remoteBooks : localBooks;

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
      try {
        await removeRemoteBook(book);
      } catch (e) {
        debugPrint('DELETE REMOTE LIBRARY ERROR: $e');
      }

      await _bookRepository.deleteOfflineBooks(book);

      offlineBooks.removeWhere((item) => item.id == book.id);
      remoteBooks.removeWhere((item) => item.id == book.id);

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

  Future<void> loadRemoteLibrary({int userId = 1}) async {
    try {
      isLoading = true;
      errMessage = null;
      notifyListeners();

      remoteBooks = await _libraryApi.getLibrary(userId: userId);
    } catch (e) {
      errMessage = 'Khong the tai thu vien online: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRemoteBook(Book book, {int userId = 1}) async {
    var bookId = int.tryParse(book.id);
    if (bookId == null) {
      final importedBook = await _libraryApi.importGoogleBook(book.id);
      bookId = int.tryParse(importedBook.id);
    }

    if (bookId == null) {
      throw Exception('Không thể xác định mã sách để thêm vào tủ sách.');
    }

    await _libraryApi.addBook(bookId, userId: userId);
  }

  Future<void> removeRemoteBook(Book book, {int userId = 1}) async {
    final bookId = int.tryParse(book.id);
    if (bookId == null) return;
    await _libraryApi.removeBook(bookId, userId: userId);
  }
}

import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:flutter/foundation.dart';

class HomeBookProvider extends ChangeNotifier {
  final BookRepository _bookRepository;

  HomeBookProvider(this._bookRepository);

  bool isLoading = false;
  bool _homeLoaded = false;
  String? errMessage;

  List<Book> continueBooks = [];
  List<Book> libraryBooks = [];
  List<Book> recommendationBooks = [];

  Future<void> loadHomeData() async {
    if (_homeLoaded) {
      debugPrint('Home data already loaded. Skip API call.');
      return;
    }

    try {
      isLoading = true;
      errMessage = null;
      notifyListeners();

      final books = await _bookRepository.searchBooks('harry potter');

      continueBooks = books.take(4).toList();
      libraryBooks = books.skip(4).take(3).toList();
      recommendationBooks = books.skip(7).take(3).toList();

      _homeLoaded = true;

      debugPrint('===== LOAD HOME DATA SUCCESS =====');
      debugPrint('Total books: ${books.length}');
      debugPrint('Continue books: ${continueBooks.length}');
      debugPrint('Library books: ${libraryBooks.length}');
      debugPrint('Recommendation books: ${recommendationBooks.length}');
    } catch (e, stackTrace) {
      debugPrint('===== LOAD HOME DATA ERROR =====');
      debugPrint('$e');
      debugPrintStack(stackTrace: stackTrace);

      errMessage = 'Không thể tải dữ liệu sách: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchBooks(String keyword) async {
    final text = keyword.trim();

    if (text.length < 2) return;

    try {
      isLoading = true;
      errMessage = null;
      notifyListeners();

      recommendationBooks = await _bookRepository.searchBooks(text);

      debugPrint('===== SEARCH BOOKS SUCCESS =====');
      debugPrint('Keyword: $text');
      debugPrint('Result count: ${recommendationBooks.length}');
    } catch (e, stackTrace) {
      debugPrint('===== SEARCH BOOKS ERROR =====');
      debugPrint('$e');
      debugPrintStack(stackTrace: stackTrace);

      errMessage = 'Không thể tìm kiếm sách: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveBookOffline(Book book) async {
    try {
      debugPrint('===== SAVE BOOK OFFLINE =====');
      debugPrint('Book ID: ${book.id}');
      debugPrint('Title: ${book.title}');

      await _bookRepository.saveBookOffline(book);

      debugPrint('Save offline success');
    } catch (e, stackTrace) {
      debugPrint('===== SAVE BOOK OFFLINE ERROR =====');
      debugPrint('$e');
      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  void resetHomeData() {
    _homeLoaded = false;
    continueBooks.clear();
    libraryBooks.clear();
    recommendationBooks.clear();
    notifyListeners();
  }
}

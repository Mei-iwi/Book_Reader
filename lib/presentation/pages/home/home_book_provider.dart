import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:flutter/foundation.dart';

class HomeBookProvider extends ChangeNotifier {
  final BookRepository _bookRepository;
  HomeBookProvider(this._bookRepository);
  bool isLoading = false;
  String? errMessage;

  List<Book> continueBooks = [];
  List<Book> libraryBooks = [];
  List<Book> recommendationBooks = [];

  Future<void> loadHomeData() async {
    try {
      isLoading = true;
      errMessage = null;
      notifyListeners();
      final books = await _bookRepository.searchBooks('harry potter');

      continueBooks = books.take(5).toList();
      libraryBooks = books.skip(5).take(5).toList();
      recommendationBooks = books.skip(10).take(5).toList();
    } catch (e, stackTrace) {
      debugPrint('LOAD HOME DATA ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      errMessage = "Không thể tải dữ liệu sách. Vui lòng thử lại sau";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchBooks(String keyword) async {
    final text = keyword.trim();
    if (text.isEmpty) return;

    try {
      isLoading = true;
      errMessage = null;
      notifyListeners();
    } catch (e) {
      errMessage = "Không thể tìm kiếm sách";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveBookOffline(Book book) async {
    await _bookRepository.saveBookOffline(book);
  }
}

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
      final results = await Future.wait([
        _bookRepository.searchBooks('harray potter'),
        _bookRepository.searchBooks('programming'),
        _bookRepository.searchBooks('novel'),
      ]);

      continueBooks = results[0];
      libraryBooks = results[1];
      recommendationBooks = results[2];
    } catch (e) {
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
}

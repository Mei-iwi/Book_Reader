import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/usecases/search_books.dart';
import 'package:flutter/material.dart';

class BookProvider extends ChangeNotifier {
  final SearchBooks _searchBooks;

  BookProvider(this._searchBooks);

  bool isLoading = false;
  String? errorMessage;
  List<Book> books = [];
  String activeKeyword = '';

  bool get hasSearched => activeKeyword.isNotEmpty;

  Future<void> search(String keyword) async {
    final text = keyword.trim();
    if (text.isEmpty) {
      clearSearch();
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;
      activeKeyword = text;
      notifyListeners();

      books = await _searchBooks(text);
    } catch (e) {
      errorMessage = "Không thể tải danh sách. Vui lòng thử lại";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    activeKeyword = '';
    books = [];
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}

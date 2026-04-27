import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/usecases/search_books.dart';
import 'package:flutter/material.dart';

class BookProvider extends ChangeNotifier {
  final SearchBooks _searchBooks;

  BookProvider(this._searchBooks);

  bool isLoading = false;
  String? errorMessage;
  List<Book> books = [];

  Future<void> search(String keyword) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = "Không thể tải danh sách. Vui lòng thử lại";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

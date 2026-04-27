import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';

class SearchBooks {
  final BookRepository _repository;

  SearchBooks(this._repository);

  Future<List<Book>> call(String keyword) {
    if (keyword.trim().isEmpty) {
      return Future.value([]);
    }
    return _repository.searchBooks(keyword.trim());
  }
}

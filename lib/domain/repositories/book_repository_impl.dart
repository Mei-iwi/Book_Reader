import 'package:book_reader/data/datasources/remote/api/google_books_api.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  final GoogleBooksApi _googleBooksApi;
  BookRepositoryImpl(this._googleBooksApi);

  @override
  Future<Book> getBookDetail(String bookId) {
    return _googleBooksApi.getBookDetail(bookId);
  }

  @override
  Future<List<Book>> searchBooks(String keyword) {
    return _googleBooksApi.searchBooks(keyword: keyword);
  }
}

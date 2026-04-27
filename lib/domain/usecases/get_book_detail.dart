import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';

class GetBookDetail {
  final BookRepository _repository;
  GetBookDetail(this._repository);
  Future<Book> call(String bookId) {
    return _repository.getBookDetail(bookId);
  }
}

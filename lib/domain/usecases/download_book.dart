import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';

class DownloadBook {
  final BookRepository _repository;
  DownloadBook(this._repository);

  Future<void> call(Book book) {
    return _repository.downloadBook(book);
  }
}

import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';

class GetOfflineBooks {
  final BookRepository _repository;
  GetOfflineBooks(this._repository);
  Future<List<Book>> call() {
    return _repository.getOfflineBooks();
  }
}

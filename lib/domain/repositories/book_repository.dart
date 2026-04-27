import 'package:book_reader/domain/entities/book.dart';

/*
 * Đây là interface để presentation/domain không phụ thuộc trực tiếp vào Google Books.
 */
abstract class BookRepository {
  Future<List<Book>> searchBooks(String keyword);
  Future<Book> getBookDetail(String bookId);
}

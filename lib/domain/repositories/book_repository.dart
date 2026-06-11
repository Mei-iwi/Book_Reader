import 'package:book_reader/domain/entities/book.dart';

/*
 * Đây là interface để presentation/domain không phụ thuộc trực tiếp vào Google Books.
 */
abstract class BookRepository {
  Future<List<Book>> getBackendBooks({
    String? keyword,
    int page = 1,
    int pageSize = 10,
  });

  Future<List<Book>> searchBooks(
    String keyword, {
    bool onlyFreeEbooks = false,
    int maxResults = 10,
  });
  Future<Book> getBookDetail(String bookId);
  Future<String> cacheReadableText(Book book, {int? userId});

  Future<void> saveBookOffline(Book book, {int? userId});
  Future<List<Book>> getOfflineBooks({int? userId});
  Future<void> deleteOfflineBooks(Book book, {int? userId});

  Future<void> downloadBook(Book book, {int? userId});
  Future<void> saveBookMetadataOffline(Book book, {int? userId});
}

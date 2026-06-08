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
  Future<String> cacheReadableText(Book book);

  Future<void> saveBookOffline(Book book);
  Future<List<Book>> getOfflineBooks();
  Future<void> deleteOfflineBooks(Book book);

  Future<void> downloadBook(Book book);
  Future<void> saveBookMetadataOffline(Book book);
}

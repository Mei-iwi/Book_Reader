import 'package:book_reader/data/datasources/local/dao/offline_book_dao.dart';
import 'package:book_reader/data/datasources/local/file_cache/book_file_downloader.dart';
import 'package:book_reader/data/datasources/remote/api/google_books_api.dart';
import 'package:book_reader/data/models/book_model.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  final GoogleBooksApi _googleBooksApi;
  final OfflineBookDao _offlineBookDao;
  final BookFileDownloader _bookFileDownloader;

  BookRepositoryImpl(
    this._googleBooksApi,
    this._offlineBookDao,
    this._bookFileDownloader,
  );

  @override
  Future<Book> getBookDetail(String bookId) {
    return _googleBooksApi.getBookDetail(bookId);
  }

  @override
  Future<List<Book>> searchBooks(String keyword) {
    return _googleBooksApi.searchBooks(keyword: keyword);
  }

  @override
  Future<void> deleteOfflineBooks(String bookId) {
    return _offlineBookDao.deleteOfflineBook(bookId);
  }

  @override
  Future<List<Book>> getOfflineBooks() {
    return _offlineBookDao.getOfflineBooks();
  }

  @override
  Future<void> saveBookOffline(Book book) async {
    final bookModel = BookModel(
      id: book.id,
      title: book.title,
      authors: book.authors,
      description: book.description,
      thumbnailUrl: book.thumbnailUrl,
      categories: book.categories,
      pageCount: book.pageCount,
      language: book.language,
      previewLink: book.previewLink,
      webReaderLink: book.webReaderLink,
      source: book.source,
      pdfDownloadLink: book.pdfDownloadLink,
      epudDownloadLink: book.epudDownloadLink,
      localFilePath: book.localFilePath,
      isDownloaded: true,
    );
    await _offlineBookDao.insertOrUpdateBook(bookModel);
  }

  @override
  Future<void> downloadBook(Book book) async {
    final hasEpub = book.epudDownloadLink.isNotEmpty;
    final hasPdf = book.pdfDownloadLink.isNotEmpty;

    if (!hasEpub && !hasPdf) {
      await saveBookMetadataOffline(book);
      return;
    }
    final downloadUrl = hasEpub ? book.epudDownloadLink : book.pdfDownloadLink;

    final extention = hasEpub ? 'epub' : 'pdf';

    final localPath = await _bookFileDownloader.downloadBookFile(
      bookId: book.id,
      downloadUrl: downloadUrl,
      extention: extention,
    );
    final downloadedbook = BookModel.fromEntity(
      book,
      isDownloaded: localPath != null,
      localFilePath: localPath ?? '',
    );
    await _offlineBookDao.insertOrUpdateBook(downloadedbook);
  }

  @override
  Future<void> saveBookMetadataOffline(Book book) async {
    final bookModel = BookModel.fromEntity(
      book,
      isDownloaded: false,
      localFilePath: '',
    );
    await _offlineBookDao.insertOrUpdateBook(bookModel);
  }
}

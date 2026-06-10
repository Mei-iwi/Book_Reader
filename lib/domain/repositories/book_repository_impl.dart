import 'dart:io';

import 'package:book_reader/data/datasources/local/dao/offline_book_dao.dart';
import 'package:book_reader/data/datasources/local/file_cache/book_file_downloader.dart';
import 'package:book_reader/data/datasources/remote/api/backend_books_api.dart';
import 'package:book_reader/data/datasources/remote/api/google_books_api.dart';
import 'package:book_reader/data/datasources/remote/api/gutendex_api.dart';
import 'package:book_reader/data/models/book_model.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BookRepositoryImpl implements BookRepository {
  final BackendBooksApi _backendBooksApi;
  final GoogleBooksApi _googleBooksApi;
  final GutendexApi _gutendexApi;
  final OfflineBookDao _offlineBookDao;
  final BookFileDownloader _bookFileDownloader;
  final Map<String, Future<Book>> _bookDetailCache = {};

  BookRepositoryImpl(
    this._backendBooksApi,
    this._googleBooksApi,
    this._gutendexApi,
    this._offlineBookDao,
    this._bookFileDownloader,
  );

  @override
  Future<List<Book>> getBackendBooks({
    String? keyword,
    int page = 1,
    int pageSize = 10,
  }) {
    return _backendBooksApi.getBooks(
      keyword: keyword,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<Book> getBookDetail(String bookId) async {
    final id = bookId.trim();
    if (id.isEmpty) {
      throw Exception('Ma sach khong hop le.');
    }

    final cachedFuture = _bookDetailCache[id];
    if (cachedFuture != null) return cachedFuture;

    final future = _getBookDetailUncached(id);
    _bookDetailCache[id] = future;

    try {
      return await future;
    } catch (_) {
      _bookDetailCache.remove(id);
      rethrow;
    }
  }

  @override
  Future<List<Book>> searchBooks(
    String keyword, {
    bool onlyFreeEbooks = false,
    int maxResults = 10,
  }) async {
    final results = await Future.wait<List<Book>>([
      _safeBackendSearch(keyword, maxResults),
      _safeGoogleSearch(
        keyword: keyword,
        maxResults: maxResults,
        onlyFreeEbooks: onlyFreeEbooks,
      ),
      _safeGutendexSearch(keyword, maxResults),
    ]);

    final backendBooks = results[0];
    final googleBooks = results[1];
    final gutendexBooks = results[2];

    final merged = <String, Book>{};
    final orderedBooks = onlyFreeEbooks
        ? [...backendBooks, ...gutendexBooks, ...googleBooks]
        : [...backendBooks, ...googleBooks, ...gutendexBooks];

    for (final book in orderedBooks) {
      merged.putIfAbsent(book.id, () => book);
      if (merged.length >= maxResults) break;
    }

    return merged.values.toList();
  }

  Future<Book> _getBookDetailUncached(String bookId) async {
    final localBook = await _offlineBookDao.getBookById(bookId);
    if (localBook != null) return localBook;

    if (_gutendexApi.isGutendexId(bookId)) {
      return _gutendexApi.getBookDetail(bookId);
    }

    return _googleBooksApi.getBookDetail(bookId);
  }

  Future<List<Book>> _safeBackendSearch(String keyword, int maxResults) async {
    try {
      return await _backendBooksApi.getBooks(
        keyword: keyword,
        pageSize: maxResults,
      );
    } catch (_) {
      return [];
    }
  }

  Future<List<Book>> _safeGoogleSearch({
    required String keyword,
    required int maxResults,
    required bool onlyFreeEbooks,
  }) async {
    try {
      return await _googleBooksApi.searchBooks(
        keyword: keyword,
        maxResult: maxResults,
        onlyFreeEbooks: onlyFreeEbooks,
      );
    } catch (_) {
      return [];
    }
  }

  Future<List<Book>> _safeGutendexSearch(String keyword, int maxResults) async {
    try {
      return await _gutendexApi.searchBooks(
        keyword: keyword,
        maxResult: maxResults,
      );
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> deleteOfflineBooks(Book book) {
    return _offlineBookDao.deleteOfflineBook(book.id);
  }

  @override
  Future<List<Book>> getOfflineBooks() {
    return _offlineBookDao.getOfflineBooks();
  }

  @override
  Future<void> saveBookOffline(Book book) async {
    String localFilePath = book.localFilePath;

    if (_isGutendexBook(book)) {
      localFilePath = await cacheReadableText(book);
    }

    final hasEpub = book.epubDownloadLink.trim().isNotEmpty;
    final hasPdf = book.pdfDownloadLink.trim().isNotEmpty;

    if (localFilePath.trim().isNotEmpty) {
      final bookModel = BookModel.fromEntity(
        book,
        localFilePath: localFilePath,
        isDownloaded: true,
      );
      await _offlineBookDao.insertOrUpdateBook(bookModel);
      return;
    }

    if (hasEpub) {
      localFilePath = await _bookFileDownloader.downloadBookFile(
        bookId: book.id,
        downloadUrl: book.epubDownloadLink,
        extension: 'epub',
      );
    } else if (hasPdf) {
      localFilePath = await _bookFileDownloader.downloadBookFile(
        bookId: book.id,
        downloadUrl: book.pdfDownloadLink,
        extension: 'pdf',
      );
    }

    final bookModel = BookModel.fromEntity(
      book,
      localFilePath: localFilePath,
      isDownloaded: localFilePath.isNotEmpty || book.isDownloaded,
    );

    await _offlineBookDao.insertOrUpdateBook(bookModel);
  }

  @override
  Future<void> downloadBook(Book book) async {
    if (_isGutendexBook(book)) {
      final localPath = await cacheReadableText(book);
      final downloadedBook = BookModel.fromEntity(
        book,
        isDownloaded: localPath.isNotEmpty,
        localFilePath: localPath,
      );
      await _offlineBookDao.insertOrUpdateBook(downloadedBook);
      return;
    }

    final hasEpub = book.epubDownloadLink.isNotEmpty;
    final hasPdf = book.pdfDownloadLink.isNotEmpty;

    if (!hasEpub && !hasPdf) {
      await saveBookMetadataOffline(book);
      return;
    }
    final downloadUrl = hasEpub ? book.epubDownloadLink : book.pdfDownloadLink;

    final extention = hasEpub ? 'epub' : 'pdf';

    final localPath = await _bookFileDownloader.downloadBookFile(
      bookId: book.id,
      downloadUrl: downloadUrl,
      extension: extention,
    );
    final downloadedbook = BookModel.fromEntity(
      book,
      isDownloaded: localPath.isNotEmpty,
      localFilePath: localPath,
    );
    await _offlineBookDao.insertOrUpdateBook(downloadedbook);
  }

  @override
  Future<void> saveBookMetadataOffline(Book book) async {
    final existing = await _offlineBookDao.getBookById(book.id);
    final bookModel = BookModel.fromEntity(
      book,
      isDownloaded: existing?.isDownloaded ?? false,
      localFilePath: existing?.localFilePath ?? '',
    );
    await _offlineBookDao.insertOrUpdateBook(bookModel);
  }

  @override
  Future<String> cacheReadableText(Book book) async {
    if (book.localFilePath.trim().isNotEmpty) {
      final file = File(book.localFilePath);
      if (await file.exists() && await file.length() > 0) {
        return book.localFilePath;
      }
    }

    if (!_isGutendexBook(book)) {
      throw Exception('Sach nay khong co API full text de tai ve.');
    }

    final content = await _gutendexApi.fetchPlainText(book);
    final directory = await getApplicationDocumentsDirectory();
    final safeBookId = book.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filePath = p.join(directory.path, 'books', '$safeBookId.txt');
    final file = File(filePath);

    await file.parent.create(recursive: true);
    await file.writeAsString(content);

    final cachedBook = BookModel.fromEntity(
      book,
      localFilePath: filePath,
      isDownloaded: true,
    );
    await _offlineBookDao.insertOrUpdateBook(cachedBook);

    return filePath;
  }

  bool _isGutendexBook(Book book) {
    return book.source == GutendexApi.source ||
        _gutendexApi.isGutendexId(book.id);
  }
}

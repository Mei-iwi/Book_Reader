import 'package:book_reader/data/datasources/local/dao/reading_progress_dao.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:flutter/foundation.dart';

class HomeBookProvider extends ChangeNotifier {
  final BookRepository _bookRepository;
  static const Duration _cacheDuration = Duration(minutes: 30);

  HomeBookProvider(this._bookRepository);

  bool isLoading = false;
  bool _homeLoaded = false;
  DateTime? _lastHomeLoadAt;
  int? _loadedUserId;
  String? errMessage;

  List<Book> continueBooks = [];
  List<Book> libraryBooks = [];
  List<Book> recommendationBooks = [];
  Map<String, List<Book>> recommendationSections = {};
  List<Book> searchResults = [];
  String activeSearchKeyword = '';

  Future<void> loadHomeData({bool forceRefresh = false, int? userId}) async {
    final cacheStillFresh =
        _lastHomeLoadAt != null &&
        DateTime.now().difference(_lastHomeLoadAt!) < _cacheDuration;
    final sameUser = _loadedUserId == userId;

    if (_homeLoaded && cacheStillFresh && sameUser && !forceRefresh) {
      debugPrint('Home data already loaded. Skip API call.');
      return;
    }

    try {
      isLoading = true;
      errMessage = null;
      notifyListeners();

      final savedBooks = await _bookRepository.getOfflineBooks(userId: userId);
      final continueReadingBooksFuture = _loadContinueBooks(
        savedBooks,
        userId: userId,
      );
      final continueReadingBooks = await continueReadingBooksFuture;

      continueBooks = continueReadingBooks;
      libraryBooks = savedBooks.take(6).toList();
      recommendationSections = {};
      recommendationBooks = [];
      searchResults = [];
      activeSearchKeyword = '';

      _homeLoaded = true;
      _lastHomeLoadAt = DateTime.now();
      _loadedUserId = userId;
      isLoading = false;
      notifyListeners();

      final recommendationResults = await Future.wait([
        _loadRecommendationSection(
          freeQuery: 'public domain fiction',
          paidQuery: 'fiction bestseller',
        ),
        _loadRecommendationSection(
          freeQuery: 'free computer programming',
          paidQuery: 'computer programming',
        ),
        _loadRecommendationSection(
          freeQuery: 'public domain science',
          paidQuery: 'science books',
        ),
      ]);

      recommendationSections = {
        'Free Fiction': recommendationResults[0].take(5).toList(),
        'Free Technology': recommendationResults[1].take(5).toList(),
        'Free Science': recommendationResults[2].take(5).toList(),
      };
      recommendationBooks = recommendationSections.values
          .expand((books) => books)
          .toList();

      debugPrint('===== LOAD HOME DATA SUCCESS =====');
      debugPrint('Google recommendation books: ${recommendationBooks.length}');
      debugPrint('Saved library books: ${savedBooks.length}');
      debugPrint('Continue books: ${continueBooks.length}');
      debugPrint('Library books: ${libraryBooks.length}');
      debugPrint('Recommendation books: ${recommendationBooks.length}');
    } catch (e, stackTrace) {
      debugPrint('===== LOAD HOME DATA ERROR =====');
      debugPrint('$e');
      debugPrintStack(stackTrace: stackTrace);

      errMessage = 'Không thể tải dữ liệu sách: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchBooks(String keyword) async {
    final text = keyword.trim();

    if (text.isEmpty) {
      clearSearch();
      return;
    }

    if (text.length < 2) return;

    try {
      isLoading = true;
      errMessage = null;
      notifyListeners();

      activeSearchKeyword = text;
      searchResults = await _bookRepository.searchBooks(
        text,
        onlyFreeEbooks: true,
        maxResults: 15,
      );

      debugPrint('===== SEARCH BOOKS SUCCESS =====');
      debugPrint('Keyword: $text');
      debugPrint('Result count: ${searchResults.length}');
    } catch (e, stackTrace) {
      debugPrint('===== SEARCH BOOKS ERROR =====');
      debugPrint('$e');
      debugPrintStack(stackTrace: stackTrace);

      errMessage = 'Không thể tìm kiếm sách: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveBookOffline(Book book, {int? userId}) async {
    try {
      debugPrint('===== SAVE BOOK OFFLINE =====');
      debugPrint('Book ID: ${book.id}');
      debugPrint('Title: ${book.title}');

      await _bookRepository.saveBookOffline(book, userId: userId);
      if (!libraryBooks.any((item) => item.id == book.id)) {
        libraryBooks = [book, ...libraryBooks].take(6).toList();
      }
      notifyListeners();

      debugPrint('Save offline success');
    } catch (e, stackTrace) {
      debugPrint('===== SAVE BOOK OFFLINE ERROR =====');
      debugPrint('$e');
      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  void resetHomeData() {
    _homeLoaded = false;
    _lastHomeLoadAt = null;
    _loadedUserId = null;
    continueBooks.clear();
    libraryBooks.clear();
    recommendationBooks.clear();
    recommendationSections.clear();
    searchResults.clear();
    activeSearchKeyword = '';
    notifyListeners();
  }

  Future<List<Book>> _loadRecommendationSection({
    required String freeQuery,
    required String paidQuery,
  }) async {
    try {
      final freeBooks = await _bookRepository.searchBooks(
        freeQuery,
        onlyFreeEbooks: true,
        maxResults: 5,
      );
      if (freeBooks.isNotEmpty) return freeBooks.take(5).toList();

      final paidBooks = await _bookRepository.searchBooks(
        paidQuery,
        onlyFreeEbooks: false,
        maxResults: 5,
      );
      return paidBooks.take(5).toList();
    } catch (e) {
      debugPrint('LOAD RECOMMENDATION SECTION ERROR: $e');
      return [];
    }
  }

  Future<List<Book>> _loadContinueBooks(
    List<Book> savedBooks, {
    int? userId,
  }) async {
    final progressRows = await ReadingProgressDao(
      AppDatabase.instance,
    ).getContinueProgress(limit: 5, userId: userId);
    if (progressRows.isEmpty) return [];

    final savedById = {for (final book in savedBooks) book.id: book};
    final bookFutures = <Future<Book?>>[];
    final addedIds = <String>{};

    for (final row in progressRows) {
      final bookId = row['book_id']?.toString() ?? '';
      if (bookId.isEmpty || addedIds.contains(bookId)) continue;
      addedIds.add(bookId);

      final cachedBook = savedById[bookId];
      if (cachedBook != null) {
        bookFutures.add(Future.value(cachedBook));
        continue;
      }

      bookFutures.add(_loadContinueBookDetail(bookId));
    }

    final books = (await Future.wait(bookFutures)).whereType<Book>();
    return books.take(5).toList();
  }

  Future<Book?> _loadContinueBookDetail(String bookId) async {
    try {
      return await _bookRepository.getBookDetail(bookId);
    } catch (e) {
      debugPrint('LOAD CONTINUE BOOK DETAIL ERROR: $e');
      return null;
    }
  }

  void clearSearch() {
    activeSearchKeyword = '';
    searchResults.clear();
    errMessage = null;
    notifyListeners();
  }

  void refreshLibraryPreview(List<Book> books) {
    libraryBooks = books.take(6).toList();
    notifyListeners();
  }

  Future<void> refreshLocalData({int? userId}) async {
    try {
      final savedBooks = await _bookRepository.getOfflineBooks(userId: userId);
      continueBooks = await _loadContinueBooks(savedBooks, userId: userId);
      libraryBooks = savedBooks.take(6).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('REFRESH HOME LOCAL DATA ERROR: $e');
    }
  }
}

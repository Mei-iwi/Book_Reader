import 'package:book_reader/data/datasources/local/dao/reading_progress_dao.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:flutter/foundation.dart';

class HomeBookProvider extends ChangeNotifier {
  final BookRepository _bookRepository;
  final ReadingProgressDao _readingProgressDao;

  HomeBookProvider(this._bookRepository, this._readingProgressDao);

  bool isLoading = false;
  bool _homeLoaded = false;
  String? errMessage;

  List<Book> continueBooks = [];
  List<Book> libraryBooks = [];
  List<Book> recommendationBooks = [];
  Map<String, List<Book>> recommendationSections = {};
  List<Book> searchResults = [];
  String activeSearchKeyword = '';

  Future<void> loadHomeData() async {
    if (_homeLoaded) {
      debugPrint('Home data already loaded. Skip API call.');
      await _refreshLocalHomeData();
      return;
    }

    try {
      isLoading = true;
      errMessage = null;
      notifyListeners();

      final savedBooks = await _bookRepository.getOfflineBooks();
      final freeFiction = await _loadRecommendationSection(
        freeQuery: 'public domain fiction',
        paidQuery: 'fiction bestseller',
      );
      final freeTechnology = await _loadRecommendationSection(
        freeQuery: 'free computer programming',
        paidQuery: 'computer programming',
      );
      final freeScience = await _loadRecommendationSection(
        freeQuery: 'public domain science',
        paidQuery: 'science books',
      );

      continueBooks = [];
      libraryBooks = savedBooks.take(6).toList();
      recommendationSections = {
        'Free Fiction': freeFiction.take(5).toList(),
        'Free Technology': freeTechnology.take(5).toList(),
        'Free Science': freeScience.take(5).toList(),
      };
      recommendationBooks = recommendationSections.values
          .expand((books) => books)
          .toList();
      searchResults = [];
      activeSearchKeyword = '';

      _homeLoaded = true;

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

  Future<void> saveBookOffline(Book book) async {
    try {
      debugPrint('===== SAVE BOOK OFFLINE =====');
      debugPrint('Book ID: ${book.id}');
      debugPrint('Title: ${book.title}');

      await _bookRepository.saveBookOffline(book);
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
}

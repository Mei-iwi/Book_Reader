import 'dart:convert';

import 'package:book_reader/config/env.dart';
import 'package:book_reader/core/constants/api_constants.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/models/book_model.dart';
import 'package:http/http.dart' as http;

class GoogleBooksApi {
  final ApiClient _apiClient;
  static const String _googleBooksApiKey = Env.googleBooksApiKey;

  GoogleBooksApi(this._apiClient);

  Future<List<BookModel>> searchBooks({
    required String keyword,
    int startIndex = 0,
    int maxResult = 10,
    String? langRestrict,
    bool onlyFreeEbooks = false,
  }) async {
    final directBooks = await _searchGoogleDirect(
      keyword: keyword,
      startIndex: startIndex,
      maxResult: maxResult,
      langRestrict: langRestrict,
      onlyFreeEbooks: onlyFreeEbooks,
    );
    if (directBooks.isNotEmpty) return directBooks;

    try {
      final googleData = await _apiClient.get(
        ApiConstants.backendBaseUrl,
        ApiConstants.googleBooksSearch,
        queryParameters: {
          'keyword': keyword,
          'startIndex': startIndex.toString(),
          'maxResults': maxResult.toString(),
          ...(langRestrict == null ? {} : {'langRestrict': langRestrict}),
          'onlyFreeEbooks': onlyFreeEbooks.toString(),
        },
      );

      final googleItems = googleData as List<dynamic>? ?? [];
      if (googleItems.isNotEmpty) {
        final books = googleItems
            .map(
              (item) => BookModel.fromBackendJson(item as Map<String, dynamic>),
            )
            .toList();
        if (onlyFreeEbooks) {
          return _prioritizePdfBooks(books.where(_isFreeAndReadable).toList());
        }
        return books;
      }
    } catch (_) {}

    return [];
  }

  Future<BookModel> getBookDetail(String bookId) async {
    final endpoint = int.tryParse(bookId) == null
        ? '${ApiConstants.books}/google/$bookId'
        : '${ApiConstants.books}/$bookId';

    try {
      final data = await _apiClient.get(ApiConstants.backendBaseUrl, endpoint);
      return BookModel.fromBackendJson(data as Map<String, dynamic>);
    } catch (_) {
      if (int.tryParse(bookId) != null) rethrow;
      final uri = Uri.https('www.googleapis.com', '/books/v1/volumes/$bookId', {
        if (_googleBooksApiKey.trim().isNotEmpty) 'key': _googleBooksApiKey,
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Khong the tai chi tiet sach Google Books.');
      }
      return BookModel.fromGoogleBooksJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
  }

  Future<List<BookModel>> _searchGoogleDirect({
    required String keyword,
    required int startIndex,
    required int maxResult,
    String? langRestrict,
    required bool onlyFreeEbooks,
  }) async {
    try {
      final query = <String, String>{
        'q': keyword,
        'startIndex': startIndex.toString(),
        'maxResults': maxResult.toString(),
        if (langRestrict != null && langRestrict.trim().isNotEmpty)
          'langRestrict': langRestrict,
        if (onlyFreeEbooks) 'filter': 'free-ebooks',
        if (_googleBooksApiKey.trim().isNotEmpty) 'key': _googleBooksApiKey,
      };
      final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', query);
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) return [];

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final items = decoded['items'] as List<dynamic>? ?? [];
      final books = items
          .map(
            (item) =>
                BookModel.fromGoogleBooksJson(item as Map<String, dynamic>),
          )
          .toList();
      if (onlyFreeEbooks) {
        return _prioritizePdfBooks(books.where(_isFreeAndReadable).toList());
      }
      return books;
    } catch (_) {
      return [];
    }
  }

  bool _isFreeAndReadable(BookModel book) {
    final hasReader =
        book.webReaderLink.trim().isNotEmpty ||
        book.previewLink.trim().isNotEmpty;
    final hasFile =
        book.pdfDownloadLink.trim().isNotEmpty ||
        book.epubDownloadLink.trim().isNotEmpty;
    return book.isFree && (hasReader || hasFile);
  }

  List<BookModel> _prioritizePdfBooks(List<BookModel> books) {
    final sorted = [...books];
    sorted.sort((a, b) {
      final aHasPdf = a.pdfDownloadLink.trim().isNotEmpty ? 0 : 1;
      final bHasPdf = b.pdfDownloadLink.trim().isNotEmpty ? 0 : 1;
      return aHasPdf.compareTo(bHasPdf);
    });
    return sorted;
  }
}

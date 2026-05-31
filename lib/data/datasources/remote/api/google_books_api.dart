import 'package:book_reader/core/constants/api_constants.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/models/book_model.dart';

class GoogleBooksApi {
  final ApiClient _apiClient;

  GoogleBooksApi(this._apiClient);

  Future<List<BookModel>> searchBooks({
    required String keyword,
    int startIndex = 0,
    int maxResult = 10,
    String? langRestrict,
    bool onlyFreeEbooks = false,
  }) async {
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
        return googleItems
            .map(
              (item) => BookModel.fromBackendJson(item as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (_) {
      // Neu Google Books bi gioi han hoac loi mang, thu tim trong SQL Server.
    }

    final data = await _apiClient.get(
      ApiConstants.backendBaseUrl,
      ApiConstants.books,
      queryParameters: {
        'keyword': keyword,
        'page': '1',
        'pageSize': maxResult.toString(),
      },
    );
    final items = data as List<dynamic>? ?? [];
    return items
        .map((item) => BookModel.fromBackendJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BookModel> getBookDetail(String bookId) async {
    final endpoint = int.tryParse(bookId) == null
        ? '${ApiConstants.books}/google/$bookId'
        : '${ApiConstants.books}/$bookId';

    final data = await _apiClient.get(ApiConstants.backendBaseUrl, endpoint);
    return BookModel.fromBackendJson(data as Map<String, dynamic>);
  }
}

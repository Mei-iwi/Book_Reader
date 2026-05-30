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
    final data = await _apiClient.get(
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

    final items = data as List<dynamic>? ?? [];
    return items
        .map((item) => BookModel.fromBackendJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BookModel> getBookDetail(String bookId) async {
    final data = await _apiClient.get(
      ApiConstants.backendBaseUrl,
      '${ApiConstants.books}/$bookId',
    );
    return BookModel.fromBackendJson(data as Map<String, dynamic>);
  }
}

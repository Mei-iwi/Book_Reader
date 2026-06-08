import 'package:book_reader/core/constants/api_constants.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/models/book_model.dart';

class BackendBooksApi {
  final ApiClient _apiClient;

  BackendBooksApi(this._apiClient);

  Future<List<BookModel>> getBooks({
    String? keyword,
    int page = 1,
    int pageSize = 10,
  }) async {
    final data = await _apiClient.get(
      ApiConstants.backendBaseUrl,
      ApiConstants.books,
      queryParameters: {
        if (keyword != null && keyword.trim().isNotEmpty)
          'keyword': keyword.trim(),
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final items = data is List<dynamic> ? data : <dynamic>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(BookModel.fromBackendJson)
        .toList();
  }
}

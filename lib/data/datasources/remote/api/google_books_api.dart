import 'package:book_reader/config/env.dart';
import 'package:book_reader/core/constants/api_constants.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/models/book_model.dart';

/*
 * Tích hợp Google Books API.
 */
class GoogleBooksApi {
  final ApiClient _apiClient;

  GoogleBooksApi(this._apiClient);

  Future<List<BookModel>> searchBooks({
    required String keyword,
    int startIndex = 0,
    int maxResult = 20,
    String? langRestrict,
  }) async {
    final data = await _apiClient.get(
      ApiConstants.googleBooksBaseUrl,
      ApiConstants.volumesEndpoint,
      queryParameters: {
        'q': keyword,
        'startIndex': startIndex.toString(),
        'maxResult': maxResult.toString(),
        'projection': 'lite',
        if (langRestrict != null) 'langeRestrict': langRestrict,
      },
    );

    final items = data['items'] as List<dynamic>? ?? [];

    return items
        .map(
          (item) => BookModel.fromGoogleBooksJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<BookModel> getBookDetail(String volumeId) async {
    final data = await _apiClient.get(
      ApiConstants.googleBooksBaseUrl,
      '${ApiConstants.volumesEndpoint}/$volumeId',
      queryParameters: {'key': Env.googleBooksApiKey},
    );
    return BookModel.fromGoogleBooksJson(data);
  }
}

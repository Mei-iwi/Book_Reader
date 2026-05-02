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
    int maxResult = 10,
    String? langRestrict,
    bool onlyFreeEbooks = false,
  }) async {
    final data = await _apiClient.get(
      ApiConstants.googleBooksBaseUrl,
      ApiConstants.volumesEndpoint,
      queryParameters: {
        'q': keyword,
        'startIndex': startIndex.toString(),
        'maxResults': maxResult.toString(),
        'projection': 'full',
        'key': Env.googleBooksApiKey,

        if (langRestrict != null) 'langRestrict': langRestrict,

        // Ưu tiên sách có full text miễn phí
        if (onlyFreeEbooks) 'filter': 'free-ebooks',

        // Nếu chỉ muốn sách có EPUB
        // 'download': 'epub',
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

import 'package:book_reader/core/constants/api_constants.dart';
import 'package:book_reader/core/services/http/api_client.dart';

class BookmarkApi {
  final ApiClient _apiClient;

  BookmarkApi(this._apiClient);

  Future<void> addBookmark({
    required int bookId,
    required int page,
    String? note,
    int? userId,
  }) async {
    await _apiClient.post(
      ApiConstants.backendBaseUrl,
      ApiConstants.bookmarks,
      queryParameters: userId == null ? null : {'userId': userId.toString()},
      body: {'bookId': bookId, 'page': page, 'note': note},
    );
  }
}

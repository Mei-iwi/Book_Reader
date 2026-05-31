import 'package:book_reader/core/constants/api_constants.dart';
import 'package:book_reader/core/services/http/api_client.dart';

class ReadingProgressApi {
  final ApiClient _apiClient;

  ReadingProgressApi(this._apiClient);

  Future<void> saveProgress({
    required int bookId,
    required int currentPage,
    required double progressPercent,
    int? userId,
  }) async {
    await _apiClient.put(
      ApiConstants.backendBaseUrl,
      '${ApiConstants.readingProgress}/$bookId',
      queryParameters: userId == null ? null : {'userId': userId.toString()},
      body: {
        'currentPage': currentPage,
        'progressPercent': progressPercent,
      },
    );
  }
}

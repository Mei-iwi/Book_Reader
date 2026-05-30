import 'package:book_reader/core/constants/api_constants.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/models/book_model.dart';

class LibraryApi {
  final ApiClient _apiClient;

  LibraryApi(this._apiClient);

  Future<List<BookModel>> getLibrary({int? userId}) async {
    final data = await _apiClient.get(
      ApiConstants.backendBaseUrl,
      ApiConstants.library,
      queryParameters: userId == null ? null : {'userId': userId.toString()},
    );
    final items = data as List<dynamic>? ?? [];
    return items
        .map((item) => BookModel.fromBackendJson(
              (item as Map<String, dynamic>)['book'] as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> addBook(int bookId, {int? userId}) async {
    await _apiClient.post(
      ApiConstants.backendBaseUrl,
      '${ApiConstants.library}/$bookId',
      queryParameters: userId == null ? null : {'userId': userId.toString()},
    );
  }

  Future<void> removeBook(int bookId, {int? userId}) async {
    await _apiClient.delete(
      ApiConstants.backendBaseUrl,
      '${ApiConstants.library}/$bookId',
      queryParameters: userId == null ? null : {'userId': userId.toString()},
    );
  }
}

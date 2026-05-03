import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class BookFileDownloader {
  final Dio _dio;

  BookFileDownloader({Dio? dio}) : _dio = dio ?? Dio();

  Future<String> downloadBookFile({
    required String bookId,
    required String downloadUrl,
    required String extension,
  }) async {
    if (downloadUrl.trim().isEmpty) return '';

    final directory = await getApplicationDocumentsDirectory();
    final filePath = join(directory.path, 'books', '$bookId.$extension');

    await _dio.download(
      downloadUrl.replaceFirst('http://', 'https://'),
      filePath,
    );

    return filePath;
  }
}

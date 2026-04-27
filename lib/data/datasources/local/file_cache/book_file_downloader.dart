import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class BookFileDownloader {
  final Dio _dio;

  BookFileDownloader({Dio? dio}) : _dio = dio ?? Dio();

  Future<String?> downloadBookFile({
    required String bookId,
    required String downloadUrl,
    required String extention,
  }) async {
    if (downloadUrl.trim().isEmpty) return null;

    final directory = await getApplicationCacheDirectory();

    final fileName = '$bookId.$extention';

    final filePath = join(directory.path, fileName);

    await _dio.download(downloadUrl, filePath);

    return filePath;
  }
}

import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.authors,
    required super.description,
    required super.thumbnailUrl,
    required super.categories,
    required super.pageCount,
    required super.language,
    required super.previewLink,
    required super.webReaderLink,
    required super.source,
  });

  factory BookModel.fromGoogleBooksJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final accessInfo = json['accessInfo'] as Map<String, dynamic>? ?? {};

    return BookModel(
      id: json['id']?.toString() ?? '',
      title: volumeInfo['title']?.toString() ?? 'Không có tiêu đề',

      authors:
          (volumeInfo['authors'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],

      description: volumeInfo['description']?.toString() ?? 'Chưa có mô tả',

      thumbnailUrl: _getGoogleBookThumbnail(volumeInfo),

      categories:
          (volumeInfo['categories'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],

      pageCount: volumeInfo['pageCount'] is int
          ? volumeInfo['pageCount'] as int
          : 0,

      language: volumeInfo['language']?.toString() ?? '',
      previewLink: volumeInfo['previewLink']?.toString() ?? '',
      webReaderLink: accessInfo['webReaderLink']?.toString() ?? '',
      source: 'google_books',
    );
  }

  static String _getGoogleBookThumbnail(Map<String, dynamic> volumeInfo) {
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;

    if (imageLinks == null) return '';

    final url =
        imageLinks['thumbnail']?.toString() ??
        imageLinks['smallThumbnail']?.toString() ??
        imageLinks['small']?.toString() ??
        imageLinks['medium']?.toString() ??
        imageLinks['large']?.toString() ??
        imageLinks['extraLarge']?.toString() ??
        '';

    return url.replaceFirst('http://', 'https://');
  }
}

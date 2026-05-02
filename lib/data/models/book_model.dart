import 'dart:convert';
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

    super.pdfDownloadLink,
    super.epubDownloadLink,
    super.localFilePath,
    super.isDownloaded,
    super.coverLocalPath,
  });

  factory BookModel.fromGoogleBooksJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final accessInfo = json['accessInfo'] as Map<String, dynamic>? ?? {};

    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};
    final pdf = accessInfo['pdf'] as Map<String, dynamic>? ?? {};
    final epub = accessInfo['epub'] as Map<String, dynamic>? ?? {};

    return BookModel(
      id: json['id']?.toString() ?? '',
      title: volumeInfo['title']?.toString() ?? 'No title',
      authors:
          (volumeInfo['authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: volumeInfo['description']?.toString() ?? '',
      thumbnailUrl: imageLinks['thumbnail']?.toString() ?? '',
      categories:
          (volumeInfo['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      pageCount: volumeInfo['pageCount'] is int
          ? volumeInfo['pageCount'] as int
          : 0,
      language: volumeInfo['language']?.toString() ?? '',
      previewLink: volumeInfo['previewLink']?.toString() ?? '',
      webReaderLink: accessInfo['webReaderLink']?.toString() ?? '',
      source: 'google_books',

      pdfDownloadLink: pdf['downloadLink']?.toString() ?? '',
      epubDownloadLink: epub['downloadLink']?.toString() ?? '',

      localFilePath: '',
      coverLocalPath: '',
      isDownloaded: false,
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

  static List<String> _decodeStringList(dynamic value) {
    if (value == null || value.toString().isEmpty) return [];
    try {
      final decoded = jsonDecode(value.toString()) as List<dynamic>;
      return decoded.map((item) => item.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  factory BookModel.fromSqlite(Map<String, dynamic> map) {
    return BookModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      authors: _decodeStringList(map['authors']),
      description: map['description']?.toString() ?? '',
      thumbnailUrl: map['thumbnail_url']?.toString() ?? '',
      categories: _decodeStringList(map['categories']),
      pageCount: map['page_count'] is int ? map['page_count'] as int : 0,
      language: map['language']?.toString() ?? '',
      previewLink: map['preview_link']?.toString() ?? '',
      webReaderLink: map['web_reader_link'],
      source: map['source']?.toString() ?? 'google_books',
      pdfDownloadLink: map['pdf_download_link']?.toString() ?? '',
      epubDownloadLink: map['epub_download_link']?.toString() ?? '',
      localFilePath: map['local_file_path']?.toString() ?? '',
      isDownloaded: map['is_downloaded'] == 1,
    );
  }
  Map<String, dynamic> toSqliteMap() {
    final now = DateTime.now().toIso8601String();

    return {
      'id': id,
      'title': title,
      'authors': jsonEncode(authors),
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'categories': jsonEncode(categories),
      'page_count': pageCount,
      'language': language,
      'preview_link': previewLink,
      'web_reader_link': webReaderLink,
      'source': source,
      'pdf_download_link': pdfDownloadLink,
      'epub_download_link': epubDownloadLink,
      'local_file_path': localFilePath,
      'cover_local_path': '',
      'is_downloaded': isDownloaded ? 1 : 0,
      'downloaded_at': now,
      'updated_at': now,
    };
  }

  BookModel copyWith({String? localFilePaht, bool? isDownloaded}) {
    return BookModel(
      id: id,
      title: title,
      authors: authors,
      description: description,
      thumbnailUrl: thumbnailUrl,
      categories: categories,
      pageCount: pageCount,
      language: language,
      previewLink: previewLink,
      webReaderLink: webReaderLink,
      source: source,
      pdfDownloadLink: pdfDownloadLink,
      epubDownloadLink: epubDownloadLink,
      localFilePath: localFilePath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  factory BookModel.fromEntity(
    Book book, {
    String? localFilePath,
    bool? isDownloaded,
  }) {
    return BookModel(
      id: book.id,
      title: book.title,
      authors: book.authors,
      description: book.description,
      thumbnailUrl: book.thumbnailUrl,
      categories: book.categories,
      pageCount: book.pageCount,
      language: book.language,
      previewLink: book.previewLink,
      webReaderLink: book.webReaderLink,
      source: book.source,
      pdfDownloadLink: book.pdfDownloadLink,
      epubDownloadLink: book.epubDownloadLink,
      localFilePath: localFilePath ?? book.localFilePath,
      isDownloaded: isDownloaded ?? book.isDownloaded,
    );
  }
}

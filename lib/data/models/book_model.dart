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
    super.isFree,
  });

  factory BookModel.fromGoogleBooksJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final accessInfo = json['accessInfo'] as Map<String, dynamic>? ?? {};
    final saleInfo = json['saleInfo'] as Map<String, dynamic>? ?? {};

    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};
    final pdf = accessInfo['pdf'] as Map<String, dynamic>? ?? {};
    final epub = accessInfo['epub'] as Map<String, dynamic>? ?? {};
    final saleability = saleInfo['saleability']?.toString() ?? '';
    final accessViewStatus = accessInfo['accessViewStatus']?.toString() ?? '';
    final hasDownload =
        (pdf['downloadLink']?.toString() ?? '').isNotEmpty ||
        (epub['downloadLink']?.toString() ?? '').isNotEmpty;

    return BookModel(
      id: json['id']?.toString() ?? '',
      title: volumeInfo['title']?.toString() ?? 'No title',
      authors:
          (volumeInfo['authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: volumeInfo['description']?.toString() ?? '',
      thumbnailUrl: _safeImageUrl(imageLinks['thumbnail']?.toString() ?? ''),
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
      isFree:
          saleability == 'FREE' ||
          hasDownload ||
          accessViewStatus == 'FULL_PUBLIC',
    );
  }

  factory BookModel.fromBackendJson(Map<String, dynamic> json) {
    List<String> readStringList(dynamic value) {
      return (value as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          <String>[];
    }

    final googleBookId = json['googleBookId']?.toString() ?? '';
    final backendId = json['id']?.toString() ?? '';
    final hasBackendId = backendId.trim().isNotEmpty && backendId.trim() != '0';
    final source = json['source']?.toString() ?? 'backend';

    return BookModel(
      id: hasBackendId ? backendId : googleBookId,
      title: json['title']?.toString() ?? 'No title',
      authors: readStringList(json['authors']),
      description: json['description']?.toString() ?? '',
      thumbnailUrl: _safeImageUrl(json['thumbnailUrl']?.toString() ?? ''),
      categories: readStringList(json['categories']),
      pageCount: json['pageCount'] is int ? json['pageCount'] as int : 0,
      language: json['language']?.toString() ?? '',
      previewLink: json['previewLink']?.toString() ?? '',
      webReaderLink: json['webReaderLink']?.toString() ?? '',
      source: source,
      pdfDownloadLink: json['pdfDownloadLink']?.toString() ?? '',
      epubDownloadLink: json['epubDownloadLink']?.toString() ?? '',
      localFilePath: json['localFilePath']?.toString() ?? '',
      coverLocalPath: json['coverLocalPath']?.toString() ?? '',
      isDownloaded: json['isDownloaded'] == true,
      isFree: json['isFree'] != false,
    );
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
      thumbnailUrl: _safeImageUrl(map['thumbnail_url']?.toString() ?? ''),
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
      isFree: true,
    );
  }
  Map<String, dynamic> toSqliteMap() {
    final now = DateTime.now().toIso8601String();

    return {
      'id': id,
      'title': title,
      'authors': jsonEncode(authors),
      'description': description,
      'thumbnail_url': _safeImageUrl(thumbnailUrl),
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
      isFree: isFree,
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
      thumbnailUrl: _safeImageUrl(book.thumbnailUrl),
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
      isFree: book.isFree,
    );
  }

  static String _safeImageUrl(String value) {
    final text = value.trim();
    if (text.isEmpty) return '';

    final uri = Uri.tryParse(text);
    if (uri == null) return '';

    if (uri.host == 'example.com') return '';
    if (uri.scheme == 'http') {
      return uri.replace(scheme: 'https').toString();
    }

    return text;
  }
}

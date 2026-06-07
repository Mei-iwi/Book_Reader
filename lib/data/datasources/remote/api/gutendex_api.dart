import 'dart:convert';

import 'package:book_reader/data/models/book_model.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:http/http.dart' as http;

class GutendexApi {
  static const String source = 'gutendex';
  static const String idPrefix = 'gutendex_';

  bool isGutendexId(String bookId) => bookId.startsWith(idPrefix);

  Future<List<BookModel>> searchBooks({
    required String keyword,
    int maxResult = 10,
  }) async {
    try {
      final text = keyword.trim();
      if (text.isEmpty) return [];

      final uri = Uri.https('gutendex.com', '/books', {
        'search': text,
        'mime_type': 'text/plain',
        'languages': 'en',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) return [];

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final results = decoded['results'] as List<dynamic>? ?? [];

      return results
          .map((item) => _mapBook(item as Map<String, dynamic>))
          .where((book) => book.webReaderLink.trim().isNotEmpty)
          .take(maxResult)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<BookModel> getBookDetail(String bookId) async {
    final rawId = _rawGutendexId(bookId);
    final uri = Uri.https('gutendex.com', '/books/$rawId');
    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Khong the tai chi tiet sach Gutendex.');
    }

    return _mapBook(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<String> fetchPlainText(Book book) async {
    final url = book.webReaderLink.trim();
    if (url.isEmpty) {
      throw Exception('Sach nay khong co link text/plain de doc truc tiep.');
    }

    final response = await http
        .get(Uri.parse(url.replaceFirst('http://', 'https://')))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Khong the tai noi dung sach.');
    }

    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }

  BookModel _mapBook(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? '';
    final formats = json['formats'] as Map<String, dynamic>? ?? {};
    final authors = json['authors'] as List<dynamic>? ?? [];
    final subjects = json['subjects'] as List<dynamic>? ?? [];

    final textUrl = _pickFormat(formats, [
      'text/plain; charset=utf-8',
      'text/plain; charset=us-ascii',
      'text/plain',
    ]);
    final htmlUrl = _pickFormat(formats, [
      'text/html; charset=utf-8',
      'text/html; charset=us-ascii',
      'text/html',
    ]);

    return BookModel(
      id: '$idPrefix$rawId',
      title: json['title']?.toString() ?? 'No title',
      authors: authors
          .map((item) {
            final map = item as Map<String, dynamic>;
            return map['name']?.toString() ?? '';
          })
          .where((name) => name.trim().isNotEmpty)
          .toList(),
      description: 'Public domain book from Project Gutenberg.',
      thumbnailUrl: formats['image/jpeg']?.toString() ?? '',
      categories: subjects
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .take(4)
          .toList(),
      pageCount: 0,
      language: _firstLanguage(json),
      previewLink: htmlUrl.isNotEmpty
          ? htmlUrl
          : 'https://www.gutenberg.org/ebooks/$rawId',
      webReaderLink: textUrl,
      source: source,
      epubDownloadLink: formats['application/epub+zip']?.toString() ?? '',
      pdfDownloadLink: formats['application/pdf']?.toString() ?? '',
      isFree: true,
    );
  }

  String _firstLanguage(Map<String, dynamic> json) {
    final languages = json['languages'] as List<dynamic>? ?? [];
    if (languages.isEmpty) return '';
    return languages.first.toString();
  }

  String _pickFormat(Map<String, dynamic> formats, List<String> preferredKeys) {
    for (final key in preferredKeys) {
      final value = formats[key]?.toString() ?? '';
      if (value.trim().isNotEmpty) return value;
    }

    for (final entry in formats.entries) {
      if (entry.key.startsWith('text/plain')) {
        return entry.value.toString();
      }
    }

    return '';
  }

  String _rawGutendexId(String bookId) {
    return bookId.startsWith(idPrefix)
        ? bookId.substring(idPrefix.length)
        : bookId;
  }
}

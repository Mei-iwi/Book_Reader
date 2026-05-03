import 'package:html/parser.dart';

class NewsModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String link; // Link để mở bài viết trên web

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    // Hàm phụ để xóa thẻ HTML khỏi text
    String parseHtmlString(String htmlString) {
      final document = parse(htmlString);
      final String parsedString = parse(document.body?.text).documentElement?.text ?? '';
      return parsedString.trim();
    }

    return NewsModel(
      id: json['id']?.toString() ?? '',
      // LitHub bọc tiêu đề và mô tả trong field 'rendered'
      title: parseHtmlString(json['title']?['rendered'] ?? 'No Title'), 
      description: parseHtmlString(json['excerpt']?['rendered'] ?? ''),
      // Lấy ảnh thumbnail từ trường jetpack_featured_media_url
      imageUrl: json['jetpack_featured_media_url']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
    );
  }
}
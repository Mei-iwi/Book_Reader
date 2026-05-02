class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final String thumbnailUrl;
  final String coverLocalPath;
  final List<String> categories;
  final int pageCount;
  final String language;
  final String previewLink;
  final String webReaderLink;
  final String source;
  final String pdfDownloadLink;
  final String epubDownloadLink;
  final String localFilePath;
  final bool isDownloaded;

  const Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.thumbnailUrl,
    this.coverLocalPath = '',
    required this.categories,
    required this.pageCount,
    required this.language,
    required this.previewLink,
    required this.webReaderLink,
    required this.source,
    this.pdfDownloadLink = '',
    this.epubDownloadLink = '',
    this.localFilePath = '',
    this.isDownloaded = false,
  });
}

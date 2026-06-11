import 'dart:io';

import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/data/datasources/local/dao/book_review_dao.dart';
import 'package:book_reader/data/datasources/local/dao/news_like_dao.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:book_reader/presentation/pages/communicate/in_app_web_page.dart';
import 'package:book_reader/presentation/pages/reader/reader.dart';
import 'package:book_reader/presentation/pages/review/reviewed_books_page.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _showGrid = false;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.userId;
      context.read<LibraryProvider>().loadOfflineBooks(userId: userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện'),
        actions: [
          IconButton(
            icon: Icon(_showGrid ? Icons.view_list : Icons.grid_view),
            tooltip: _showGrid ? 'Xem dạng danh sách' : 'Xem dạng lưới',
            onPressed: () => setState(() => _showGrid = !_showGrid),
          ),
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: 'Sách đã đánh giá',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReviewedBooksPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Import sách',
            onPressed: () => _importBook(context, provider),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(LibraryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errMessage != null) {
      return Center(child: Text(provider.errMessage!, textAlign: TextAlign.center));
    }

    final userId = context.read<AuthProvider>().currentUser?.userId;
    final categories = _categories(provider.offlineBooks);
    final books = _filteredBooks(provider);

    return RefreshIndicator(
      onRefresh: () => provider.loadOfflineBooks(userId: userId),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildFilters(categories)),
          if (_selectedCategory == 'liked_news')
            SliverToBoxAdapter(child: _buildLikedNews())
          else if (_selectedCategory == 'reviews')
            SliverToBoxAdapter(child: _buildReviewedBooks())
          else if (provider.offlineBooks.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Chưa có sách đã lưu.')),
            )
          else if (books.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Không có sách trong mục này.')),
            )
          else if (_showGrid)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _LibraryBookGridItem(book: books[index]);
                }, childCount: books.length),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return _LibraryBookItem(book: books[index], provider: provider);
                },
              ),
            ),
        ],
      ),
    );
  }

  List<String> _categories(List<Book> books) {
    final values = <String>{};
    for (final book in books) {
      for (final category in book.categories) {
        final text = category.trim();
        if (text.isNotEmpty) values.add(text);
      }
    }
    return values.toList()..sort();
  }

  List<Book> _filteredBooks(LibraryProvider provider) {
    if (_selectedCategory == 'downloaded') return provider.downloadedBooks;
    if (_selectedCategory == 'all') return provider.offlineBooks;
    if (_selectedCategory == 'reviews' || _selectedCategory == 'liked_news') {
      return const [];
    }
    return provider.offlineBooks
        .where((book) => book.categories.contains(_selectedCategory))
        .toList();
  }

  Widget _buildFilters(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _filterChip('all', 'Tất cả'),
          const SizedBox(width: 8),
          _filterChip('downloaded', 'Downloaded'),
          const SizedBox(width: 8),
          _filterChip('reviews', 'Đã đánh giá'),
          const SizedBox(width: 8),
          _filterChip('liked_news', 'Tin đã thích'),
          for (final category in categories) ...[
            const SizedBox(width: 8),
            _filterChip(category, category),
          ],
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedCategory == value,
      onSelected: (_) => setState(() => _selectedCategory = value),
    );
  }

  Widget _buildLikedNews() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: NewsLikeDao(AppDatabase.instance).getLikedNews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final news = snapshot.data ?? [];
        if (news.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('Chưa có tin tức đã thích.')),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: news.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = news[index];
            final title = item['title']?.toString() ?? 'Tin đã thích';
            final url = item['url']?.toString() ?? '';
            final imageUrl = item['image_url']?.toString() ?? '';

            return ListTile(
              leading: SizedBox(
                width: 56,
                height: 56,
                child: imageUrl.isEmpty
                    ? const Icon(Icons.article_outlined)
                    : Image.network(
                        imageUrl.replaceFirst('http://', 'https://'),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return const Icon(Icons.article_outlined);
                        },
                      ),
              ),
              title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: url.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InAppWebPage(title: title, url: url),
                        ),
                      );
                    },
            );
          },
        );
      },
    );
  }

  Widget _buildReviewedBooks() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: BookReviewDao(AppDatabase.instance).getAllReviews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('Chưa có sách đã đánh giá.')),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final review = reviews[index];
            final title = review['display_title']?.toString().trim().isNotEmpty == true
                ? review['display_title'].toString()
                : 'Sách đã đánh giá';
            final cover = review['display_cover']?.toString() ?? '';
            final rating = (review['rating'] as num?)?.toDouble() ?? 0;
            final content = review['content']?.toString() ?? '';

            return ListTile(
              leading: _BookCover(url: cover, width: 52, height: 74),
              title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${rating.toStringAsFixed(1)} sao'
                '${content.isEmpty ? '' : '\n$content'}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _importBook(BuildContext context, LibraryProvider provider) async {
    try {
      final repo = context.read<BookRepository>();
      final userId = context.read<AuthProvider>().currentUser?.userId;
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub', 'txt'],
      );

      final filePath = result?.files.single.path;
      if (filePath == null || filePath.trim().isEmpty) return;

      final fileName = result!.files.single.name;
      final newBook = Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: fileName,
        authors: const ['Local Import'],
        description: 'Imported from device',
        thumbnailUrl: '',
        categories: const ['Local'],
        pageCount: 1,
        language: 'vi',
        previewLink: '',
        webReaderLink: '',
        pdfDownloadLink: '',
        epubDownloadLink: '',
        source: 'local_import',
        localFilePath: File(filePath).path,
        coverLocalPath: '',
        isDownloaded: true,
      );

      await repo.saveBookOffline(newBook, userId: userId);
      if (!mounted) return;
      await provider.loadOfflineBooks(userId: userId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Import thành công!')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi import file: $e')));
    }
  }
}

class _LibraryBookItem extends StatelessWidget {
  final Book book;
  final LibraryProvider provider;

  const _LibraryBookItem({required this.book, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookCover(url: book.thumbnailUrl, width: 55, height: 80),
            const SizedBox(width: 12),
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.authors.isNotEmpty ? book.authors.join(', ') : 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    _ReviewText(bookId: book.id),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Đọc sách',
                      icon: const Icon(Icons.menu_book_outlined, color: Colors.blue),
                      onPressed: () => _openReader(context),
                    ),
                    IconButton(
                      tooltip: 'Xóa sách',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReader(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Reader(
          value: 1,
          total: book.pageCount > 0 ? book.pageCount : 1,
          title: book.title,
          coverUrl: book.thumbnailUrl,
          bookId: book.id,
          userId: context.read<AuthProvider>().currentUser?.userId,
          localFilePath: book.localFilePath,
          webReaderLink: book.webReaderLink,
          previewLink: book.previewLink,
          pdfDownloadLink: book.pdfDownloadLink,
          epubDownloadLink: book.epubDownloadLink,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final userId = context.read<AuthProvider>().currentUser?.userId;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa sách'),
          content: Text('Bạn có muốn xóa "${book.title}" khỏi thư viện không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    await provider.deleteOfflineBook(book, userId: userId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xóa sách khỏi thư viện')));
  }
}

class _LibraryBookGridItem extends StatelessWidget {
  final Book book;

  const _LibraryBookGridItem({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Reader(
                value: 1,
                total: book.pageCount > 0 ? book.pageCount : 1,
                title: book.title,
                coverUrl: book.thumbnailUrl,
                bookId: book.id,
                userId: context.read<AuthProvider>().currentUser?.userId,
                localFilePath: book.localFilePath,
                webReaderLink: book.webReaderLink,
                previewLink: book.previewLink,
                pdfDownloadLink: book.pdfDownloadLink,
                epubDownloadLink: book.epubDownloadLink,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _BookCover(url: book.thumbnailUrl)),
              const SizedBox(height: 8),
              Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                book.authors.isNotEmpty ? book.authors.join(', ') : 'Unknown',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              _ReviewText(bookId: book.id),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;

  const _BookCover({required this.url, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final cover = url.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: cover.isEmpty
            ? Image.asset(Templateimage.book1, fit: BoxFit.cover)
            : Image.network(
                cover.replaceFirst('http://', 'https://'),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Image.asset(Templateimage.book1, fit: BoxFit.cover);
                },
              ),
      ),
    );
  }
}

class _ReviewText extends StatelessWidget {
  final String bookId;

  const _ReviewText({required this.bookId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: BookReviewDao(AppDatabase.instance).getReview(bookId),
      builder: (context, snapshot) {
        final rating = (snapshot.data?['rating'] as num?)?.toDouble();
        if (rating == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}

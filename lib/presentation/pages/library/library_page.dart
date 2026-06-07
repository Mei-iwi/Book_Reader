import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:book_reader/presentation/pages/reader/reader.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
import 'dart:io';
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
        title: const Text(
          'Download',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_showGrid ? Icons.view_list : Icons.grid_view),
            tooltip: _showGrid ? 'Xem dang danh sach' : 'Xem dang luoi',
            onPressed: () => setState(() => _showGrid = !_showGrid),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Import Book',
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(provider.errMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    if (provider.offlineBooks.isEmpty) {
      return const Center(child: Text('Chưa có sách đã lưu.'));
    }

    final userId = context.read<AuthProvider>().currentUser?.userId;
    final categories = _categories(provider.offlineBooks);
    final books = _filteredBooks(provider);

    return RefreshIndicator(
      onRefresh: () => provider.loadOfflineBooks(userId: userId),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildFilters(categories)),
          if (books.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Khong co sach trong muc nay.')),
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
                  final book = books[index];
                  return _LibraryBookGridItem(book: book);
                }, childCount: books.length),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return _LibraryBookItem(book: book, provider: provider);
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
    final books = provider.offlineBooks;
    if (_selectedCategory == 'downloaded') {
      return provider.downloadedBooks;
    }
    if (_selectedCategory == 'all') return books;
    return books
        .where((book) => book.categories.contains(_selectedCategory))
        .toList();
  }

  Widget _buildFilters(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _filterChip('all', 'Tat ca'),
          const SizedBox(width: 8),
          _filterChip('downloaded', 'Downloaded'),
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

  Future<void> _importBook(
    BuildContext context,
    LibraryProvider provider,
  ) async {
    try {
      final repo = context.read<BookRepository>();
      final userId = context.read<AuthProvider>().currentUser?.userId;
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final fileName = result.files.single.name;

        final newBook = Book(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: fileName,
          authors: ['Local Import'],
          description: 'Imported from device',
          thumbnailUrl: '',
          categories: ['Local'],
          pageCount: 1,
          language: 'vi',
          previewLink: '',
          webReaderLink: '',
          pdfDownloadLink: '',
          epubDownloadLink: '',
          source: 'local_import',
          localFilePath: file.path,
          coverLocalPath: '',
          isDownloaded: true,
        );

        await repo.saveBookOffline(newBook);
        if (!mounted) return;
        await provider.loadOfflineBooks(userId: userId);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Import thành công!')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi import file: $e')));
      }
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
            _buildCover(),
            const SizedBox(width: 12),
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    book.authors.isNotEmpty
                        ? book.authors.join(', ')
                        : 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Đọc sách',
                      icon: const Icon(
                        Icons.menu_book_outlined,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        _openReader(context);
                      },
                    ),
                    IconButton(
                      tooltip: 'Xóa sách',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await _confirmDelete(context);
                      },
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

  Widget _buildCover() {
    return SizedBox(
      width: 55,
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _coverImage(),
      ),
    );
  }

  Widget _coverImage() {
    final thumbnail = book.thumbnailUrl.trim();

    if (thumbnail.isNotEmpty) {
      return Image.network(
        thumbnail.replaceFirst('http://', 'https://'),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _defaultCover();
        },
      );
    }

    return _defaultCover();
  }

  Widget _defaultCover() {
    return Image.asset(Templateimage.book1, fit: BoxFit.cover);
  }

  void _openReader(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Reader(
          value: 1,
          total: book.pageCount > 0 ? book.pageCount : 1,
          title: book.title,
          bookId: book.id,
          userId: context.read<AuthProvider>().currentUser?.userId,
          localFilePath: book.localFilePath,
          webReaderLink: book.webReaderLink,
          previewLink: book.previewLink,
          pdfDownloadLink: book.pdfDownloadLink,
          epubDownloadLink: book.epubDownloadLink,

          // Fallback demo nếu sách chưa có file tải thật và cũng chưa có link đọc.
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
              Expanded(child: _coverImage()),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverImage() {
    final thumbnail = book.thumbnailUrl.trim();
    if (thumbnail.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          thumbnail.replaceFirst('http://', 'https://'),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultCover(),
        ),
      );
    }
    return _defaultCover();
  }

  Widget _defaultCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(Templateimage.book1, fit: BoxFit.cover),
    );
  }
}

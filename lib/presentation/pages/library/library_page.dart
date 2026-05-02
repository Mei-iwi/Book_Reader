import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/presentation/pages/reader/reader.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().loadOfflineBooks();
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

    return RefreshIndicator(
      onRefresh: provider.loadOfflineBooks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.offlineBooks.length,
        itemBuilder: (context, index) {
          final book = provider.offlineBooks[index];

          return _LibraryBookItem(book: book, provider: provider);
        },
      ),
    );
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
        errorBuilder: (_, __, ___) {
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
          localFilePath: book.localFilePath,
          webReaderLink: book.webReaderLink,
          previewLink: book.previewLink,

          // Fallback demo nếu sách chưa có file tải thật và cũng chưa có link đọc.
          assetPath:
              book.localFilePath.trim().isEmpty &&
                  book.webReaderLink.trim().isEmpty &&
                  book.previewLink.trim().isEmpty
              ? 'assets/sample_data/templatecontentbooks/hoang_tu_be_demo.txt'
              : null,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
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

    await provider.deleteOfflineBook(book);

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xóa sách khỏi thư viện')));
  }
}

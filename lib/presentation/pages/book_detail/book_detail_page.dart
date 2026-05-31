import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:book_reader/presentation/pages/reader/reader.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Future<Book> _bookFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bookId = ModalRoute.of(context)?.settings.arguments?.toString() ?? '';
    _bookFuture = context.read<BookRepository>().getBookDetail(bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Details'), centerTitle: true),
      body: FutureBuilder<Book>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Không thể tải chi tiết sách:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final book = snapshot.data;
          if (book == null) {
            return const Center(child: Text('Không tìm thấy sách.'));
          }

          return _BookDetailContent(book: book);
        },
      ),
    );
  }
}

class _BookDetailContent extends StatelessWidget {
  final Book book;

  const _BookDetailContent({required this.book});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _buildCover()),
          const SizedBox(height: 16),
          Text(
            book.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            book.authors.isEmpty ? 'Unknown author' : book.authors.join(', '),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (book.categories.isNotEmpty)
            Text('Thể loại: ${book.categories.join(', ')}'),
          Text('Số trang: ${book.pageCount}'),
          Text('Ngôn ngữ: ${book.language.isEmpty ? 'N/A' : book.language}'),
          const SizedBox(height: 16),
          Text(book.description.isEmpty ? 'Chưa có mô tả.' : book.description),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await context.read<LibraryProvider>().addRemoteBook(book);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm vào tủ sách')),
              );
            },
            icon: const Icon(Icons.library_add),
            label: const Text('Thêm vào tủ sách'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Reader(
                    value: 1,
                    total: book.pageCount > 0 ? book.pageCount : 1,
                    title: book.title,
                    bookId: book.id,
                    webReaderLink: book.webReaderLink,
                    previewLink: book.previewLink,
                    localFilePath: book.localFilePath,
                    assetPath: book.webReaderLink.isEmpty &&
                            book.previewLink.isEmpty &&
                            book.localFilePath.isEmpty
                        ? 'assets/sample_data/templatecontentbooks/hoang_tu_be_demo.txt'
                        : null,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.menu_book),
            label: const Text('Đọc sách'),
          ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    final thumbnail = book.thumbnailUrl.trim();
    return SizedBox(
      width: 160,
      height: 230,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: thumbnail.isEmpty
            ? Image.asset(Templateimage.book1, fit: BoxFit.cover)
            : Image.network(
                thumbnail.replaceFirst('http://', 'https://'),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Image.asset(Templateimage.book1, fit: BoxFit.cover);
                },
              ),
      ),
    );
  }
}

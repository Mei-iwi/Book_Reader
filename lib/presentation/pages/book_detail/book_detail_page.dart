import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/data/datasources/local/dao/favorite_dao.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:book_reader/presentation/pages/reader/reader.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  Future<Book>? _bookFuture;
  bool _isFavorite = false;
  String _bookId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeBookId =
        ModalRoute.of(context)?.settings.arguments?.toString() ?? '';
    if (routeBookId == _bookId && _bookFuture != null) return;

    _bookId = routeBookId;
    _bookFuture = _bookId.trim().isEmpty
        ? Future<Book>.error('Ma sach khong hop le.')
        : context.read<BookRepository>().getBookDetail(_bookId);
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    if (_bookId.isEmpty) return;
    final isFav = await FavoriteDao(AppDatabase.instance).isFavorite(_bookId);
    if (!mounted) return;
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite(Book book) async {
    final dao = FavoriteDao(AppDatabase.instance);
    if (_isFavorite) {
      await dao.removeFavorite(book.id);
    } else {
      await dao.addFavorite(
        bookId: book.id,
        title: book.title,
        author: book.authors.isNotEmpty ? book.authors.first : 'Unknown',
        coverUrl: book.thumbnailUrl,
      );
    }

    if (!mounted) return;
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Da them yeu thich' : 'Da bo yeu thich'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Book>(
      future: _bookFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Khong the tai chi tiet sach:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final book = snapshot.data;
        if (book == null) {
          return const Scaffold(
            body: Center(child: Text('Khong tim thay sach.')),
          );
        }

        return _BookDetailContent(
          book: book,
          isFavorite: _isFavorite,
          onFavorite: () => _toggleFavorite(book),
        );
      },
    );
  }
}

class _BookDetailContent extends StatelessWidget {
  final Book book;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const _BookDetailContent({
    required this.book,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.black,
              size: 28,
            ),
            onPressed: onFavorite,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: _buildCover()),
              const SizedBox(height: 26),
              Text(
                book.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  text: 'Author: ',
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  children: [
                    TextSpan(
                      text: book.authors.isEmpty
                          ? 'Unknown'
                          : book.authors.first,
                      style: const TextStyle(color: Color(0xFF4B5563)),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _buildStats(context),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _readBook(context),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text(
                    'READ BOOK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF17D7F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              if (book.categories.isNotEmpty) ...[
                const SizedBox(height: 22),
                Text(
                  book.categories.take(3).join(' - '),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _StatItem(
          icon: Icons.star,
          iconColor: Colors.amber,
          value: '5.0',
          label: 'RATING',
        ),
        _StatItem(
          icon: Icons.visibility_outlined,
          iconColor: Colors.grey,
          value: book.pageCount > 0 ? book.pageCount.toString() : '72',
          label: 'VIEWS',
        ),
        InkWell(
          onTap: () => _downloadBook(context),
          borderRadius: BorderRadius.circular(12),
          child: const _StatItem(
            icon: Icons.file_download_outlined,
            iconColor: Colors.black87,
            value: '',
            label: 'DOWNLOAD',
          ),
        ),
      ],
    );
  }

  Future<void> _downloadBook(BuildContext context) async {
    final userId = context.read<AuthProvider>().currentUser?.userId;
    final libraryProvider = context.read<LibraryProvider>();

    try {
      await context.read<BookRepository>().saveBookOffline(book);
      if (userId != null) {
        try {
          await libraryProvider.addRemoteBook(book, userId: userId);
        } catch (_) {}
      }
      await libraryProvider.loadOfflineBooks(userId: userId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Da luu sach vao thu vien')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Khong the tai sach: $e')));
    }
  }

  Future<void> _readBook(BuildContext context) async {
    final isFullTextApiBook = _isFullTextApiBook;
    final canReadOnline =
        isFullTextApiBook ||
        book.webReaderLink.trim().isNotEmpty ||
        book.previewLink.trim().isNotEmpty ||
        book.localFilePath.trim().isNotEmpty ||
        book.pdfDownloadLink.trim().isNotEmpty ||
        book.epubDownloadLink.trim().isNotEmpty;

    if (!canReadOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sach nay chua co link doc online mien phi.'),
        ),
      );
      return;
    }

    var localFilePath = book.localFilePath;

    if (isFullTextApiBook) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        localFilePath = await context.read<BookRepository>().cacheReadableText(
          book,
        );
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Khong the tai noi dung sach: $e')),
          );
        }
        return;
      }

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Reader(
          value: 1,
          total: isFullTextApiBook
              ? 1
              : (book.pageCount > 0 ? book.pageCount : 1),
          title: book.title,
          bookId: book.id,
          userId: context.read<AuthProvider>().currentUser?.userId,
          webReaderLink: isFullTextApiBook ? null : book.webReaderLink,
          previewLink: isFullTextApiBook ? null : book.previewLink,
          pdfDownloadLink: book.pdfDownloadLink,
          epubDownloadLink: book.epubDownloadLink,
          localFilePath: localFilePath,
        ),
      ),
    );
  }

  bool get _isFullTextApiBook {
    return book.source == 'gutendex' || book.id.startsWith('gutendex_');
  }

  Widget _buildCover() {
    final thumbnail = book.thumbnailUrl.trim();
    return SizedBox(
      width: 160,
      height: 215,
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          if (value.isNotEmpty)
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

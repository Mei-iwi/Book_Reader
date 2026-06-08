import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/core/widgets/ShareWidgetProfile/historyreading.dart';
import 'package:book_reader/core/widgets/ShareWidgetProfile/item.dart';
import 'package:book_reader/core/widgets/ShareWidgetProfile/wbook.dart';
import 'package:book_reader/data/datasources/local/dao/favorite_dao.dart';
import 'package:book_reader/data/datasources/local/dao/profile_dao.dart';
import 'package:book_reader/data/datasources/local/dao/reading_progress_dao.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:book_reader/presentation/pages/profile/editprofile.dart';
import 'package:book_reader/presentation/pages/reader/reader.dart';
import 'package:book_reader/presentation/pages/review/book_review_page.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
import 'package:book_reader/presentation/state/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<StatefulWidget> createState() => _Myprofile();
}

class _Myprofile extends State<Myprofile> {
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _localProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().currentUser;
    final db = AppDatabase.instance;
    final favDao = FavoriteDao(db);
    final progDao = ReadingProgressDao(db);
    final profDao = ProfileDao(db);

    final favs = await favDao.getAllFavorites();
    await progDao.pruneOldProgress(keep: 10);
    var hist = await progDao.getRecentProgress(limit: 10);

    Map<String, dynamic>? prof;
    if (user != null) {
      prof = await profDao.getProfile(user.userId.toString());
    }

    if (mounted) {
      await context.read<LibraryProvider>().loadOfflineBooks(
        userId: user?.userId,
      );
      await _enrichHistoryRows(hist, progDao);
      hist = await progDao.getRecentProgress(limit: 10);
    }

    if (mounted) {
      setState(() {
        _favorites = favs;
        _history = hist;
        _localProfile = prof;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final libraryProvider = context.watch<LibraryProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    String fullName = 'Người dùng';
    String email = 'Chưa đăng nhập';
    String avatarPath = '';

    if (currentUser != null) {
      fullName = currentUser.fullName.trim().isNotEmpty
          ? currentUser.fullName
          : fullName;
      email = currentUser.email.trim().isNotEmpty ? currentUser.email : email;
      avatarPath = currentUser.avatarUrl;
    }

    if (_localProfile != null) {
      fullName = _localProfile!['full_name'] ?? fullName;
      email = _localProfile!['email'] ?? email;
      avatarPath = _localProfile!['avatar_path']?.toString() ?? avatarPath;
    }

    final downloadCount = libraryProvider.offlineBooks.length;
    final readingCount = _history.length;
    final readCount = _history.where((h) {
      final percent = h['progress_percent'];
      return percent is num && percent >= 100;
    }).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.restorablePushNamed(context, "/homescreen");
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          "Profile",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: themeProvider.isDarkMode
                ? 'Chuyển sang giao diện sáng'
                : 'Chuyển sang giao diện tối',
            onPressed: themeProvider.toggleTheme,
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoute.membership);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Hội viên',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: SizedBox(
                              width: 110,
                              height: 110,
                              child: CircleAvatar(
                                backgroundImage: _avatarImage(avatarPath),
                              ),
                            ),
                          ),
                          SizedBox(width: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    fullName,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfilePage(),
                                    ),
                                  );
                                  _loadData();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFE8F1F9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                    color: Color(0xFF313F58),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await context.read<AuthProvider>().logout();
                                  if (!context.mounted) return;
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoute.login,
                                    (_) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: const Text(
                                  "Đăng xuất",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Item(value: readCount, text: "Read Books"),
                          Item(value: readingCount, text: "Reading"),
                          Item(value: downloadCount, text: "Downloads"),
                        ],
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          "Favorite",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      _favorites.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(left: 20, top: 10),
                              child: Text(
                                'Chưa có sách yêu thích',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _favorites.map((fav) {
                                  return wbook(
                                    context: context,
                                    url: fav['cover_url']?.isNotEmpty == true
                                        ? fav['cover_url']
                                        : Templateimage.book1,
                                    title: fav['title'] ?? 'Unknown',
                                    author: fav['author'] ?? 'Unknown',
                                    func: () async {
                                      await Navigator.pushNamed(
                                        context,
                                        '/book-detail',
                                        arguments: fav['book_id'],
                                      );
                                      _loadData();
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          "Reading History",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      _history.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(left: 20, top: 10),
                              child: Text(
                                'Chưa có lịch sử đọc',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              child: Column(
                                children: _history.map((hist) {
                                  final bookId =
                                      hist['book_id']?.toString() ?? '';
                                  final book = _findBook(
                                    bookId,
                                    libraryProvider.offlineBooks,
                                  );
                                  final percent =
                                      (hist['progress_percent'] ?? 0)
                                          .toDouble();
                                  final historyTitle =
                                      hist['book_title']?.toString().trim() ??
                                      '';
                                  final historyCover =
                                      hist['cover_url']?.toString().trim() ??
                                      '';
                                  final displayTitle =
                                      book?.title ??
                                      (historyTitle.isNotEmpty
                                          ? historyTitle
                                          : 'Sách đang đọc');
                                  final displayCover =
                                      book?.thumbnailUrl.isNotEmpty == true
                                      ? book!.thumbnailUrl
                                      : historyCover;
                                  return bookReading(
                                    url: displayCover.isNotEmpty
                                        ? displayCover
                                        : Templateimage.book1,
                                    name: displayTitle,
                                    percent: percent,
                                    onTap: () => _openReaderFromHistory(
                                      context,
                                      hist,
                                      book,
                                    ),
                                    onDelete: () =>
                                        _deleteReadingProgress(context, bookId),
                                    action: percent >= 30
                                        ? Align(
                                            alignment: Alignment.centerLeft,
                                            child: OutlinedButton.icon(
                                                  onPressed: () =>
                                                      _openReviewPage(
                                                        context,
                                                        bookId,
                                                        displayTitle,
                                                        displayCover,
                                                        book?.authors
                                                                .join(', ') ??
                                                            '',
                                                      ),
                                              icon: const Icon(
                                                Icons.star_outline,
                                                size: 18,
                                              ),
                                              label: const Text('Đánh giá'),
                                            ),
                                          )
                                        : null,
                                  );
                                }).toList(),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  ImageProvider _avatarImage(String avatarPath) {
    final value = avatarPath.trim();
    if (value.isNotEmpty && File(value).existsSync()) {
      return FileImage(File(value));
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }
    return AssetImage(Templateimage.avatar);
  }

  Book? _findBook(String bookId, List<Book> books) {
    for (final book in books) {
      if (book.id == bookId) return book;
    }
    return null;
  }

  Future<void> _enrichHistoryRows(
    List<Map<String, dynamic>> rows,
    ReadingProgressDao progDao,
  ) async {
    final libraryBooks = context.read<LibraryProvider>().offlineBooks;
    final repo = context.read<BookRepository>();

    for (final row in rows) {
      final bookId = row['book_id']?.toString() ?? '';
      if (bookId.isEmpty) continue;

      final hasTitle =
          row['book_title']?.toString().trim().isNotEmpty == true;
      final hasCover = row['cover_url']?.toString().trim().isNotEmpty == true;
      if (hasTitle && hasCover) continue;

      Book? book = _findBook(bookId, libraryBooks);
      if (book == null) {
        try {
          book = await repo.getBookDetail(bookId);
          await repo.saveBookMetadataOffline(book);
        } catch (_) {
          book = null;
        }
      }
      if (book == null) continue;

      final currentPage = (row['current_page'] as num?)?.toInt() ?? 1;
      final totalPage =
          (row['total_page'] as num?)?.toInt() ??
          (book.pageCount > 0 ? book.pageCount : 1);
      final progressPercent =
          (row['progress_percent'] as num?)?.toDouble() ??
          ((currentPage / totalPage) * 100);

      await progDao.saveProgress(
        bookId: bookId,
        currentPage: currentPage,
        totalPage: totalPage <= 0 ? 1 : totalPage,
        progressPercent: progressPercent,
        bookTitle: book.title,
        coverUrl: book.thumbnailUrl,
      );
    }
  }

  Future<void> _deleteReadingProgress(
    BuildContext context,
    String bookId,
  ) async {
    if (bookId.isEmpty) return;

    await ReadingProgressDao(AppDatabase.instance).deleteProgress(bookId);
    await _loadData();

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xóa tiến độ đọc')));
  }

  Future<void> _openReaderFromHistory(
    BuildContext context,
    Map<String, dynamic> history,
    Book? cachedBook,
  ) async {
    final bookId = history['book_id']?.toString() ?? '';
    if (bookId.isEmpty) return;

    Book? book = cachedBook;
    if (book == null) {
      try {
        book = await context.read<BookRepository>().getBookDetail(bookId);
      } catch (_) {
        book = null;
      }
    }

    if (!context.mounted) return;

    final currentPage = history['current_page'] is int
        ? history['current_page'] as int
        : 1;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Reader(
          value: currentPage,
          total: (book?.pageCount ?? 0) > 0 ? book!.pageCount : 1,
          title:
              book?.title ??
              history['book_title']?.toString() ??
              'Sách đang đọc',
          coverUrl:
              book?.thumbnailUrl ??
              history['cover_url']?.toString() ??
              '',
          bookId: bookId,
          userId: context.read<AuthProvider>().currentUser?.userId,
          localFilePath: book?.localFilePath,
          webReaderLink: book?.webReaderLink,
          previewLink: book?.previewLink,
          pdfDownloadLink: book?.pdfDownloadLink,
          epubDownloadLink: book?.epubDownloadLink,
        ),
      ),
    );

    if (mounted) {
      _loadData();
    }
  }

  Future<void> _openReviewPage(
    BuildContext context,
    String bookId,
    String title,
    String coverUrl,
    String author,
  ) async {
    if (bookId.isEmpty) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookReviewPage(
          bookId: bookId,
          title: title,
          coverUrl: coverUrl,
          author: author,
        ),
      ),
    );
  }
}

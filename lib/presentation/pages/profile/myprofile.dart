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
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
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
  String? _loadError;
  final ReadingProgressDao _readingProgressDao = ReadingProgressDao(
    AppDatabase.instance,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final user = context.read<AuthProvider>().currentUser;
      final db = AppDatabase.instance;
      final favDao = FavoriteDao(db);
      final profDao = ProfileDao(db);

      final favs = await favDao.getAllFavorites();
      await _readingProgressDao.trimProgressHistory(maxItems: 10);
      final hist = await _readingProgressDao.getRecentProgress(limit: 10);

      Map<String, dynamic>? prof;
      if (user != null) {
        prof = await profDao.getProfile(user.userId.toString());
      }

      if (mounted) {
        setState(() {
          _favorites = favs;
          _history = hist;
          _localProfile = prof;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('PROFILE LOAD ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _loadError = 'Không thể tải dữ liệu hồ sơ. Bấm thử lại.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final libraryProvider = context.watch<LibraryProvider>();

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
    final readCount = _history
        .where((h) => h['progress_percent'] == 100.0)
        .length;

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
                      if (_loadError != null) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(_loadError!)),
                              TextButton(
                                onPressed: _loadData,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                                    rateFavourite: 1,
                                    showFavoriteCount: false,
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
                                  return bookReading(
                                    url: book?.thumbnailUrl.isNotEmpty == true
                                        ? book!.thumbnailUrl
                                        : Templateimage.book1,
                                    name:
                                        book?.title ?? 'Đang đọc (ID: $bookId)',
                                    percent: _readDouble(
                                      hist['progress_percent'],
                                    ),
                                    onTap: () => _openReaderFromHistory(
                                      context,
                                      hist,
                                      book,
                                    ),
                                    onDelete: () =>
                                        _confirmDeleteProgress(bookId),
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

  Future<void> _confirmDeleteProgress(String bookId) async {
    if (bookId.trim().isEmpty) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa tiến độ đọc'),
          content: const Text(
            'Bạn có muốn xóa tiến độ đọc của sách này không?',
          ),
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

    await _readingProgressDao.deleteProgress(bookId);
    await _loadData();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xóa tiến độ đọc')));
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

    final currentPage = _readInt(history['current_page'], fallback: 1);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Reader(
          value: currentPage,
          total: (book?.pageCount ?? 0) > 0 ? book!.pageCount : 1,
          title: book?.title ?? 'Reading',
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

    if (!mounted) return;
    await _loadData();
  }

  int _readInt(Object? value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _readDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

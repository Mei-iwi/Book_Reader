import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/core/widgets/ShareWidgetHome/form.dart';
import 'package:book_reader/core/widgets/ShareWidgetHome/wbook.dart';
import 'package:book_reader/data/datasources/local/dao/reading_progress_dao.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/presentation/pages/home/home_book_provider.dart';
import 'package:book_reader/presentation/pages/profile/myprofile.dart';
import 'package:book_reader/presentation/pages/reader/reader.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
import 'package:book_reader/presentation/state/theme_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const Home({super.key, this.onNavigateTab});

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<Home> {
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.userId;
      context.read<HomeBookProvider>().loadHomeData(userId: userId);
    });
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeBookProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: FormSearch(
          text: 'Search',
          controller: search,
          func: _openSearch,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            tooltip: themeProvider.isDarkMode
                ? 'Chuyển sang giao diện sáng'
                : 'Chuyển sang giao diện tối',
            onPressed: themeProvider.toggleTheme,
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Myprofile()),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: _homeAvatarImage(user?.avatarUrl ?? ''),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/banner.png', fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                  ),
                  const Positioned(
                    left: 18,
                    bottom: 18,
                    child: Text(
                      'Book Reader',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Trang chủ'),
              onTap: () {
                Navigator.pop(context);
                widget.onNavigateTab?.call(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_library),
              title: const Text('Thư viện'),
              onTap: () {
                Navigator.pop(context);
                widget.onNavigateTab?.call(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Cộng đồng'),
              onTap: () {
                Navigator.pop(context);
                widget.onNavigateTab?.call(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: const Text('Hội viên'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/membership');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                widget.onNavigateTab?.call(3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất'),
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: _buildBody(provider),
      ),
    );
  }

  void _openSearch() {
    Navigator.pushNamed(
      context,
      AppRoute.search,
      arguments: search.text.trim(),
    );
  }
}

ImageProvider _homeAvatarImage(String avatarPath) {
  final value = avatarPath.trim();
  if (value.isNotEmpty && File(value).existsSync()) {
    return FileImage(File(value));
  }
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return NetworkImage(value);
  }
  return AssetImage(Templateimage.avatar);
}

Widget _buildBody(HomeBookProvider provider) {
  if (provider.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  if (provider.errMessage != null) {
    return Center(child: Text(provider.errMessage!));
  }

  return SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.activeSearchKeyword.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kết quả tìm kiếm: ${provider.activeSearchKeyword}',
                  style: style(),
                ),
              ),
              TextButton(
                onPressed: provider.clearSearch,
                child: const Text('Xóa'),
              ),
            ],
          ),
          _buiderBookSection(title: '', books: provider.searchResults),
        ] else ...[
          _buiderBookSection(
            title: 'Continue...',
            books: provider.continueBooks,
            emptyMessage: 'Chưa có sách đang đọc tiếp.',
            openFromProgress: true,
          ),
          _buiderBookSection(
            title: 'From Library',
            books: provider.libraryBooks,
            emptyMessage: 'Thu vien dang trong.',
          ),
          for (final entry in provider.recommendationSections.entries)
            _buiderBookSection(
              title: 'Recommendations - ${entry.key}',
              books: entry.value,
              emptyMessage:
                  'Không tải được sách miễn phí từ Google Books cho mục này.',
            ),
        ],
      ],
    ),
  );
}

Widget _buiderBookSection({
  required String title,
  required List<Book> books,
  String emptyMessage =
      'Không tìm thấy sách hoặc Google Books đang giới hạn truy cập.',
  bool openFromProgress = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title.isNotEmpty) ...[
        Text(title, style: style()),
        const SizedBox(height: 8),
      ],

      if (books.isEmpty)
        Padding(padding: const EdgeInsets.all(12), child: Text(emptyMessage))
      else
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final book = books[index];
              return wbook(
                context: context,
                url: book.thumbnailUrl.isNotEmpty
                    ? book.thumbnailUrl
                    : Templateimage.book1,
                title: book.title,
                author: book.authors.isNotEmpty
                    ? book.authors.join(', ')
                    : "Unknow",
                isFree: book.isFree,
                func: () async {
                  if (openFromProgress) {
                    await _openReaderFromProgress(context, book);
                    return;
                  }

                  Navigator.pushNamed(
                    context,
                    '/book-detail',
                    arguments: book.id,
                  );
                },
                onDownload: () async {
                  debugPrint('===== BẤM DOWNLOAD =====');
                  debugPrint('Book title: ${book.title}');

                  final homeProvider = context.read<HomeBookProvider>();
                  final libraryProvider = context.read<LibraryProvider>();
                  final userId = context
                      .read<AuthProvider>()
                      .currentUser
                      ?.userId;

                  await homeProvider.saveBookOffline(book, userId: userId);

                  if (!context.mounted) return;

                  await libraryProvider.loadOfflineBooks(userId: userId);
                  homeProvider.refreshLibraryPreview(
                    libraryProvider.offlineBooks,
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu sách vào thư viện')),
                  );
                },
              );
            },
          ),
        ),
    ],
  );
}

Future<void> _openReaderFromProgress(BuildContext context, Book book) async {
  final progress = await ReadingProgressDao(AppDatabase.instance).getProgress(
    book.id,
    userId: context.read<AuthProvider>().currentUser?.userId,
  );
  final currentPageValue = progress?['current_page'];
  final currentPage = currentPageValue is num ? currentPageValue.toInt() : 1;

  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Reader(
        value: currentPage <= 0 ? 1 : currentPage,
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

  if (!context.mounted) return;
  await context.read<HomeBookProvider>().refreshLocalData(
    userId: context.read<AuthProvider>().currentUser?.userId,
  );
}

TextStyle style() {
  return TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
}

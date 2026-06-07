import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/core/widgets/ShareWidgetHome/form.dart';
import 'package:book_reader/core/widgets/ShareWidgetHome/wbook.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/presentation/pages/home/home_book_provider.dart';
import 'package:book_reader/presentation/pages/profile/myprofile.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
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
      context.read<HomeBookProvider>().loadHomeData();
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
    return Scaffold(
      appBar: AppBar(
        title: FormSearch(
          text: 'Search',
          controller: search,
          func: () {
            context.read<HomeBookProvider>().searchBooks(search.text);
          },
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Myprofile()),
              );
            },
            child: CircleAvatar(
              backgroundImage: AssetImage(Templateimage.avatar),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text(
                'Book Reader',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            emptyMessage: 'Chua co sach dang doc tiep.',
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
                  'Khong tai duoc sach mien phi tu Google Books cho muc nay.',
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
      'Khong tim thay sach hoac Google Books dang gioi han truy cap.',
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title.isNotEmpty) ...[
        Text(title, style: style()),
        const SizedBox(height: 8),
      ],

      if (books.isEmpty)
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(emptyMessage),
        )
      else
        SizedBox(
          height: 230,
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
                func: () {
                  if (openContinueReader) {
                    _openContinueReader(context, provider, book);
                    return;
                  }

                  Navigator.pushNamed(
                    context,
                    '/book-detail',
                    arguments: book.id,
                  );
                },
                openDirectly: openContinueReader,
                onDownload: () async {
                  debugPrint('===== BẤM DOWNLOAD =====');
                  debugPrint('Book title: ${book.title}');

                  final homeProvider = context.read<HomeBookProvider>();
                  final libraryProvider = context.read<LibraryProvider>();
                  final userId = context
                      .read<AuthProvider>()
                      .currentUser
                      ?.userId;

                  await homeProvider.saveBookOffline(book);

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

void _openContinueReader(
  BuildContext context,
  HomeBookProvider provider,
  Book book,
) {
  final progress = provider.getProgressForBook(book.id);
  final currentPage = _readInt(progress?['current_page'], fallback: 1);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Reader(
        value: currentPage > 0 ? currentPage : 1,
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
}

int _readInt(Object? value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

TextStyle style() {
  return TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
}

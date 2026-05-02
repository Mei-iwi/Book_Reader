import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/core/widgets/ShareWidgetHome/form.dart';
import 'package:book_reader/core/widgets/ShareWidgetHome/wbook.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/presentation/pages/home/home_book_provider.dart';
import 'package:book_reader/presentation/pages/profile/myprofile.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

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
        title: formSearch(
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
        child: ListView(children: [ListTile(title: Text("Menu"))]),
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
        _buiderBookSection(title: 'Continue...', books: provider.continueBooks),
        _buiderBookSection(title: 'From Library', books: provider.libraryBooks),
        _buiderBookSection(
          title: 'Recommendations',
          books: provider.recommendationBooks,
        ),
      ],
    ),
  );
}

Widget _buiderBookSection({required String title, required List<Book> books}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: style()),
      const SizedBox(height: 8),

      if (books.isEmpty)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Chưa có dữ liệu'),
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
                func: () {
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

                  await homeProvider.saveBookOffline(book);

                  if (!context.mounted) return;

                  await libraryProvider.loadOfflineBooks();

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

TextStyle style() {
  return TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
}

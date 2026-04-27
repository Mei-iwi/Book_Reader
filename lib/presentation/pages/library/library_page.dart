import 'package:book_reader/presentation/state/library_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/templateImage.dart';

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
      context.read<LibraryProvider>().loadOfflineBook();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Thư viện offline')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(LibraryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.erroerMessage != null) {
      return Center(child: Text(provider.erroerMessage!));
    }

    if (provider.offlineBooks.isEmpty) {
      return const Center(child: Text('Chưa có sách offline.'));
    }

    return ListView.builder(
      itemCount: provider.offlineBooks.length,
      itemBuilder: (context, index) {
        final book = provider.offlineBooks[index];

        return ListTile(
          leading: Image.network(
            book.thumbnailUrl,
            width: 50,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Image.asset(
                Templateimage.book1,
                width: 50,
                height: 70,
                fit: BoxFit.cover,
              );
            },
          ),
          title: Text(book.title),
          subtitle: Text(
            book.authors.isNotEmpty ? book.authors.join(', ') : 'Unknown',
          ),
          trailing: book.localFilePath.isNotEmpty
              ? const Icon(Icons.download_done, color: Colors.green)
              : const Icon(Icons.info_outline),
          onTap: () {
            if (book.localFilePath.isNotEmpty) {
              // TODO: mở file PDF/EPUB local bằng reader tương ứng.
            } else if (book.webReaderLink.isNotEmpty ||
                book.previewLink.isNotEmpty) {
              // TODO: mở preview/webReaderLink online.
            }
          },
        );
      },
    );
  }
}

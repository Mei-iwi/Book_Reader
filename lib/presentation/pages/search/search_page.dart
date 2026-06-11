import 'package:book_reader/config/routes.dart';
import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/presentation/state/book_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  bool _loadedInitialQuery = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedInitialQuery) return;
    _loadedInitialQuery = true;

    final initialKeyword =
        ModalRoute.of(context)?.settings.arguments?.toString().trim() ?? '';
    if (initialKeyword.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<BookProvider>().clearSearch();
      });
      return;
    }

    _controller.text = initialKeyword;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BookProvider>().search(initialKeyword);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch() {
    FocusScope.of(context).unfocus();
    context.read<BookProvider>().search(_controller.text);
  }

  void _clearSearch() {
    _controller.clear();
    context.read<BookProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm sách')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              _SearchInput(
                controller: _controller,
                onSubmitted: _submitSearch,
                onClear: _clearSearch,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _SearchResultBody(
                  provider: provider,
                  onRetry: _submitSearch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;

  const _SearchInput({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          autofocus: value.text.trim().isEmpty,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => onSubmitted(),
          decoration: InputDecoration(
            hintText: 'Tên sách, tác giả hoặc thể loại',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Xóa từ khóa',
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                  ),
                IconButton(
                  tooltip: 'Tìm sách',
                  onPressed: onSubmitted,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
    );
  }
}

class _SearchResultBody extends StatelessWidget {
  final BookProvider provider;
  final VoidCallback onRetry;

  const _SearchResultBody({required this.provider, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return _SearchStateMessage(
        icon: Icons.error_outline,
        title: 'Không tìm kiếm được',
        message: provider.errorMessage!,
        action: ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại'),
        ),
      );
    }

    if (!provider.hasSearched) {
      return const _SearchStateMessage(
        icon: Icons.manage_search,
        title: 'Tìm sách',
        message: 'Nhập tên sách, tác giả hoặc thể loại để bắt đầu.',
      );
    }

    if (provider.books.isEmpty) {
      return _SearchStateMessage(
        icon: Icons.menu_book_outlined,
        title: 'Không có kết quả',
        message: 'Thử một từ khóa khác hoặc kiểm tra kết nối backend.',
        action: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.search),
          label: const Text('Tìm lại'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: provider.books.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _BookSearchItem(book: provider.books[index]);
      },
    );
  }
}

class _BookSearchItem extends StatelessWidget {
  final Book book;

  const _BookSearchItem({required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final author = book.authors.isEmpty
        ? 'Chưa rõ tác giả'
        : book.authors.join(', ');
    final categories = book.categories.take(2).join(' - ');

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openDetail(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _BookCover(url: book.thumbnailUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (categories.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        categories,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _InfoPill(
                          label: book.isFree ? 'Miễn phí' : 'Có phí',
                          color: book.isFree ? Colors.green : Colors.red,
                        ),
                        _InfoPill(
                          label: _sourceLabel(book.source),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Xem chi tiết',
                onPressed: () => _openDetail(context),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.pushNamed(context, AppRoute.bookDetail, arguments: book.id);
  }

  String _sourceLabel(String source) {
    return switch (source) {
      'google_books' => 'Google Books',
      'gutendex' => 'Gutendex',
      'local' => 'Backend',
      '' => 'Backend',
      _ => source,
    };
  }
}

class _BookCover extends StatelessWidget {
  final String url;

  const _BookCover({required this.url});

  @override
  Widget build(BuildContext context) {
    final value = url.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 72,
        height: 104,
        child: value.startsWith('http://') || value.startsWith('https://')
            ? Image.network(
                value.replaceFirst('http://', 'https://'),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallbackCover(),
              )
            : _assetCover(value),
      ),
    );
  }

  Widget _assetCover(String value) {
    final asset = value.isEmpty ? Templateimage.book4 : value;
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _fallbackCover(),
    );
  }

  Widget _fallbackCover() {
    return Image.asset(Templateimage.book4, fit: BoxFit.cover);
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SearchStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _SearchStateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/data/datasources/local/dao/book_review_dao.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:flutter/material.dart';

class BookReviewPage extends StatefulWidget {
  final String bookId;
  final String title;
  final String coverUrl;
  final String author;

  const BookReviewPage({
    super.key,
    required this.bookId,
    required this.title,
    this.coverUrl = '',
    this.author = '',
  });

  @override
  State<BookReviewPage> createState() => _BookReviewPageState();
}

class _BookReviewPageState extends State<BookReviewPage> {
  final _contentController = TextEditingController();
  final _reviewDao = BookReviewDao(AppDatabase.instance);
  double _rating = 5;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadReview() async {
    final review = await _reviewDao.getReview(widget.bookId);
    if (!mounted) return;

    setState(() {
      _rating = (review?['rating'] as num?)?.toDouble() ?? 5;
      _contentController.text = review?['content']?.toString() ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveReview() async {
    setState(() => _isSaving = true);

    await _reviewDao.saveReview(
      bookId: widget.bookId,
      bookTitle: widget.title,
      coverUrl: widget.coverUrl,
      rating: _rating,
      content: _contentController.text,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu đánh giá sách')));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title.trim().isEmpty ? 'Sách đã đọc' : widget.title;

    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá sách')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCover(),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (widget.author.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Tác giả: ${widget.author}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 28),
                    _buildStars(),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _contentController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Nội dung đánh giá',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveReview,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.star),
                        label: const Text('Lưu đánh giá'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCover() {
    final cover = widget.coverUrl.trim();
    return SizedBox(
      width: 160,
      height: 215,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: cover.isEmpty
            ? Image.asset(Templateimage.book1, fit: BoxFit.cover)
            : Image.network(
                cover.replaceFirst('http://', 'https://'),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Image.asset(Templateimage.book1, fit: BoxFit.cover);
                },
              ),
      ),
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        return IconButton(
          onPressed: () => setState(() => _rating = value.toDouble()),
          icon: Icon(
            value <= _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 34,
          ),
        );
      }),
    );
  }
}

import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/data/datasources/local/dao/book_review_dao.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:flutter/material.dart';

class ReviewedBooksPage extends StatelessWidget {
  const ReviewedBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sách đã đánh giá')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: BookReviewDao(AppDatabase.instance).getAllReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) {
            return const Center(child: Text('Chưa có sách nào được đánh giá.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final review = reviews[index];
              final title =
                  review['display_title']?.toString().trim().isNotEmpty == true
                  ? review['display_title'].toString()
                  : 'Sách đã đánh giá';
              final cover = review['display_cover']?.toString() ?? '';
              final rating = (review['rating'] as num?)?.toDouble() ?? 0;
              final content = review['content']?.toString() ?? '';

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 52,
                    height: 74,
                    child: cover.trim().isEmpty
                        ? Image.asset(Templateimage.book1, fit: BoxFit.cover)
                        : Image.network(
                            cover.replaceFirst('http://', 'https://'),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) {
                              return Image.asset(
                                Templateimage.book1,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                  ),
                ),
                title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${rating.toStringAsFixed(1)} sao'
                  '${content.isEmpty ? '' : '\n$content'}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';
import 'package:sqflite/sqflite.dart';

class BookReviewDao {
  final AppDatabase _appDatabase;

  BookReviewDao(this._appDatabase);

  Future<Map<String, dynamic>?> getReview(String bookId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      TableNames.bookReviews,
      where: 'book_id = ?',
      whereArgs: [bookId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<void> saveReview({
    required String bookId,
    String? bookTitle,
    String? coverUrl,
    required double rating,
    required String content,
  }) async {
    final db = await _appDatabase.database;
    final now = DateTime.now().toIso8601String();
    final existing = await getReview(bookId);

    await db.insert(TableNames.bookReviews, {
      'book_id': bookId,
      'book_title': bookTitle,
      'cover_url': coverUrl,
      'rating': rating,
      'content': content.trim(),
      'created_at': existing?['created_at']?.toString() ?? now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllReviews() async {
    final db = await _appDatabase.database;
    return db.rawQuery('''
      SELECT
        r.*,
        COALESCE(r.book_title, b.title) AS display_title,
        COALESCE(r.cover_url, b.thumbnail_url) AS display_cover,
        b.authors AS display_authors
      FROM ${TableNames.bookReviews} r
      LEFT JOIN ${TableNames.offlineBooks} b ON b.id = r.book_id
      ORDER BY r.updated_at DESC
    ''');
  }
}

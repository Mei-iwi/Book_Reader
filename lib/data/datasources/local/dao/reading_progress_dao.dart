import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';

class ReadingProgressDao {
  final AppDatabase _appDatabase;

  ReadingProgressDao(this._appDatabase);

  Future<void> saveProgress({
    required String bookId,
    required int currentPage,
    required int totalPage,
    required double progressPercent,
    String? bookTitle,
    String? coverUrl,
  }) async {
    final db = await _appDatabase.database;

    final existing = await db.query(
      TableNames.readingProgress,
      where: 'book_id = ?',
      whereArgs: [bookId],
      limit: 1,
    );
    final data = {
      'book_id': bookId,
      'book_title': bookTitle,
      'cover_url': coverUrl,
      'current_page': currentPage,
      'total_page': totalPage,
      'progress_percent': progressPercent,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (existing.isEmpty) {
      await db.insert(TableNames.readingProgress, data);
    } else {
      await db.update(
        TableNames.readingProgress,
        data,
        where: 'book_id = ?',
        whereArgs: [bookId],
      );
    }
  }

  Future<Map<String, dynamic>?> getProgress(String bookId) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      TableNames.readingProgress,
      where: 'book_id = ?',
      whereArgs: [bookId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<List<Map<String, dynamic>>> getAllProgress() async {
    final db = await _appDatabase.database;
    return await db.query(
      TableNames.readingProgress,
      orderBy: 'updated_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getRecentProgress({int limit = 10}) async {
    final db = await _appDatabase.database;
    return await db.query(
      TableNames.readingProgress,
      orderBy: 'updated_at DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getContinueProgress({
    int limit = 5,
  }) async {
    final db = await _appDatabase.database;
    return await db.query(
      TableNames.readingProgress,
      where: 'progress_percent > ? AND progress_percent < ?',
      whereArgs: [0, 100],
      orderBy: 'progress_percent DESC, updated_at DESC',
      limit: limit,
    );
  }

  Future<void> deleteProgress(String bookId) async {
    final db = await _appDatabase.database;
    await db.delete(
      TableNames.readingProgress,
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
  }

  Future<void> pruneOldProgress({int keep = 10}) async {
    if (keep < 1) return;

    final db = await _appDatabase.database;
    await db.delete(
      TableNames.readingProgress,
      where:
          'id NOT IN (SELECT id FROM ${TableNames.readingProgress} ORDER BY updated_at DESC LIMIT ?)',
      whereArgs: [keep],
    );
  }
}

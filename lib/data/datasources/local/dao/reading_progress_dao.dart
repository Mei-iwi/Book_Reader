import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';

class ReadingProgressDao {
  final AppDatabase _appDatabase;

  ReadingProgressDao(this._appDatabase);

  int _scope(int? userId) => userId ?? 0;

  Future<void> saveProgress({
    required String bookId,
    required int currentPage,
    required int totalPage,
    required double progressPercent,
    String? bookTitle,
    String? coverUrl,
    int? userId,
  }) async {
    final db = await _appDatabase.database;
    final safeTotalPage = totalPage <= 0 ? 1 : totalPage;
    final safeCurrentPage = currentPage.clamp(1, safeTotalPage).toInt();
    final calculatedPercent = (safeCurrentPage / safeTotalPage) * 100;
    final safeProgressPercent =
        progressPercent.isNaN || progressPercent.isInfinite
        ? calculatedPercent.clamp(0, 100).toDouble()
        : progressPercent.clamp(0, 100).toDouble();

    final existing = await db.query(
      TableNames.readingProgress,
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [_scope(userId), bookId],
      limit: 1,
    );
    final data = {
      'user_id': _scope(userId),
      'book_id': bookId,
      'book_title': bookTitle,
      'cover_url': coverUrl,
      'current_page': safeCurrentPage,
      'total_page': safeTotalPage,
      'progress_percent': safeProgressPercent,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (existing.isEmpty) {
      await db.insert(TableNames.readingProgress, data);
    } else {
      await db.update(
        TableNames.readingProgress,
        data,
        where: 'user_id = ? AND book_id = ?',
        whereArgs: [_scope(userId), bookId],
      );
    }
  }

  Future<Map<String, dynamic>?> getProgress(String bookId, {int? userId}) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      TableNames.readingProgress,
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [_scope(userId), bookId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<List<Map<String, dynamic>>> getAllProgress({int? userId}) async {
    final db = await _appDatabase.database;
    return await db.query(
      TableNames.readingProgress,
      where: 'user_id = ?',
      whereArgs: [_scope(userId)],
      orderBy: 'updated_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getRecentProgress({
    int limit = 10,
    int? userId,
  }) async {
    final db = await _appDatabase.database;
    return await db.query(
      TableNames.readingProgress,
      where: 'user_id = ?',
      whereArgs: [_scope(userId)],
      orderBy: 'updated_at DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getContinueProgress({
    int limit = 5,
    int? userId,
  }) async {
    final db = await _appDatabase.database;
    return await db.query(
      TableNames.readingProgress,
      where: 'user_id = ? AND progress_percent > ? AND progress_percent < ?',
      whereArgs: [_scope(userId), 0, 100],
      orderBy: 'progress_percent DESC, updated_at DESC',
      limit: limit,
    );
  }

  Future<void> deleteProgress(String bookId, {int? userId}) async {
    final db = await _appDatabase.database;
    await db.delete(
      TableNames.readingProgress,
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [_scope(userId), bookId],
    );
  }

  Future<void> pruneOldProgress({int keep = 10, int? userId}) async {
    if (keep < 1) return;

    final db = await _appDatabase.database;
    await db.delete(
      TableNames.readingProgress,
      where:
          'user_id = ? AND id NOT IN (SELECT id FROM ${TableNames.readingProgress} WHERE user_id = ? ORDER BY updated_at DESC LIMIT ?)',
      whereArgs: [_scope(userId), _scope(userId), keep],
    );
  }
}

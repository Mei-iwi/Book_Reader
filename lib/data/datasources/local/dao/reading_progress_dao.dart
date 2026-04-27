import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';

class ReadingProgressDao {
  final AppDatabase _appDatabase;

  ReadingProgressDao(this._appDatabase);

  Future<void> saveProgress({
    required String bookId,
    required int currentPage,
    required double progressPercent,
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
      'current_page': currentPage,
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
}

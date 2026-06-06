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

  Future<List<Map<String, dynamic>>> getAllProgress() async {
    final db = await _appDatabase.database;
    return await db.query(
      TableNames.readingProgress,
      orderBy: 'updated_at DESC',
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

  Future<List<Map<String, dynamic>>> getTopProgress({
    int limit = 5,
    bool sortByProgressDesc = true,
  }) async {
    if (limit < 1) return [];

    final db = await _appDatabase.database;
    return await db.query(
      TableNames.readingProgress,
      where: 'progress_percent > ?',
      whereArgs: [0],
      orderBy: sortByProgressDesc
          ? 'progress_percent DESC, updated_at DESC, id DESC'
          : 'updated_at DESC, id DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getRecentProgress({int limit = 10}) async {
    if (limit < 1) return [];

    final db = await _appDatabase.database;
    return await db.query(
      TableNames.readingProgress,
      orderBy: 'updated_at DESC, id DESC',
      limit: limit,
    );
  }

  Future<void> trimProgressHistory({int maxItems = 10}) async {
    if (maxItems < 1) return;

    final db = await _appDatabase.database;
    final oldRows = await db.rawQuery(
      '''
      SELECT id
      FROM ${TableNames.readingProgress}
      ORDER BY updated_at DESC, id DESC
      LIMIT -1 OFFSET ?
      ''',
      [maxItems],
    );

    if (oldRows.isEmpty) return;

    final ids = oldRows
        .map((row) => row['id'])
        .whereType<int>()
        .toList(growable: false);
    if (ids.isEmpty) return;

    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete(
      TableNames.readingProgress,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }
}

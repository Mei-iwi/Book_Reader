import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';

class BookmarkDao {
  final AppDatabase _appDatabase;

  BookmarkDao(this._appDatabase);

  int _scope(int? userId) => userId ?? 0;

  Future<void> addBookmark({
    required String bookId,
    required int page,
    String? note,
    int? userId,
  }) async {
    final db = await _appDatabase.database;
    final now = DateTime.now().toIso8601String();
    final existing = await db.query(
      TableNames.bookmarks,
      where: 'user_id = ? AND book_id = ? AND page = ?',
      whereArgs: [_scope(userId), bookId, page],
      limit: 1,
    );
    final data = {
      'user_id': _scope(userId),
      'book_id': bookId,
      'page': page,
      'note': note ?? '',
      'created_at': now,
    };

    if (existing.isEmpty) {
      await db.insert(TableNames.bookmarks, data);
    } else {
      await db.update(
        TableNames.bookmarks,
        data,
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getBookmarks(
    String bookId, {
    int? userId,
  }) async {
    final db = await _appDatabase.database;
    return db.query(
      TableNames.bookmarks,
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [_scope(userId), bookId],
      orderBy: 'page ASC',
    );
  }

  Future<void> deleteBookmark(int bookmarkId, {int? userId}) async {
    final db = await _appDatabase.database;
    await db.delete(
      TableNames.bookmarks,
      where: 'user_id = ? AND id = ?',
      whereArgs: [_scope(userId), bookmarkId],
    );
  }

  Future<Map<String, int>> countByBookIds(
    Iterable<String> bookIds, {
    int? userId,
  }) async {
    final ids = bookIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (ids.isEmpty) return {};

    final db = await _appDatabase.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.rawQuery('''
      SELECT book_id, COUNT(*) AS bookmark_count
      FROM ${TableNames.bookmarks}
      WHERE user_id = ? AND book_id IN ($placeholders)
      GROUP BY book_id
      ''', [_scope(userId), ...ids]);

    return {
      for (final row in rows)
        row['book_id'].toString(): (row['bookmark_count'] as num).toInt(),
    };
  }
}

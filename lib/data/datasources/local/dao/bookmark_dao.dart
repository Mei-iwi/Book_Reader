import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';

class BookmarkDao {
  final AppDatabase _appDatabase;

  BookmarkDao(this._appDatabase);
  Future<void> addBookmark({
    required String bookId,
    required int page,
    String? note,
  }) async {
    final db = await _appDatabase.database;
    final now = DateTime.now().toIso8601String();
    final existing = await db.query(
      TableNames.bookmarks,
      where: 'book_id = ? AND page = ?',
      whereArgs: [bookId, page],
      limit: 1,
    );
    final data = {
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

  Future<List<Map<String, dynamic>>> getBookmarks(String bookId) async {
    final db = await _appDatabase.database;
    return db.query(
      TableNames.bookmarks,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'page ASC',
    );
  }

  Future<void> deleteBookmark(int bookmarkId) async {
    final db = await _appDatabase.database;
    await db.delete(
      TableNames.bookmarks,
      where: 'id = ?',
      whereArgs: [bookmarkId],
    );
  }

  Future<Map<String, int>> countByBookIds(Iterable<String> bookIds) async {
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
      WHERE book_id IN ($placeholders)
      GROUP BY book_id
      ''', ids);

    return {
      for (final row in rows)
        row['book_id'].toString(): (row['bookmark_count'] as num).toInt(),
    };
  }
}

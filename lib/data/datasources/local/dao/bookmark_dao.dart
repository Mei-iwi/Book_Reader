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
    await db.insert(TableNames.bookmarks, {
      'book_id': bookId,
      'page': page,
      'note': note ?? '',
      'created_at': DateTime.now().toIso8601String(),
    });
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
      where: 'book_id = ?',
      whereArgs: [bookmarkId],
    );
  }
}

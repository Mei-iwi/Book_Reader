import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';
import 'package:book_reader/data/models/book_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class OfflineBookDao {
  final AppDatabase _appDatabase;

  OfflineBookDao(this._appDatabase);

  int _scope(int? userId) => userId ?? 0;

  Future<void> insertOrUpdateBook(BookModel book, {int? userId}) async {
    final db = await _appDatabase.database;
    final data = book.toSqliteMap();
    data['user_id'] = _scope(userId);

    await db.insert(
      TableNames.offlineBooks,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('===== DA LUU SACH OFFLINE =====');
    debugPrint('User ID: ${_scope(userId)}');
    debugPrint('ID: ${book.id}');
    debugPrint('Title: ${book.title}');
    debugPrint('Authors: ${book.authors.join(', ')}');
    debugPrint('Thumbnail: ${book.thumbnailUrl}');
    debugPrint('Local file: ${book.localFilePath}');
    debugPrint('Is downloaded: ${book.isDownloaded}');

    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM offline_books WHERE user_id = ?',
        [_scope(userId)],
      ),
    );

    debugPrint('Tong so sach offline cua user: $count');
  }

  Future<List<BookModel>> getOfflineBooks({int? userId}) async {
    final db = await _appDatabase.database;

    final maps = await db.query(
      TableNames.offlineBooks,
      where: 'user_id = ?',
      whereArgs: [_scope(userId)],
      orderBy: 'downloaded_at DESC',
    );

    return maps.map((map) => BookModel.fromSqlite(map)).toList();
  }

  Future<BookModel?> getBookById(String bookId, {int? userId}) async {
    final db = await _appDatabase.database;

    final maps = await db.query(
      TableNames.offlineBooks,
      where: 'user_id = ? AND id = ?',
      whereArgs: [_scope(userId), bookId],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return BookModel.fromSqlite(maps.first);
  }

  Future<void> deleteOfflineBook(String bookId, {int? userId}) async {
    final db = await _appDatabase.database;

    await db.delete(
      TableNames.offlineBooks,
      where: 'user_id = ? AND id = ?',
      whereArgs: [_scope(userId), bookId],
    );
  }

  Future<void> updateDownloadedFilePath({
    required String bookId,
    required String localFilePath,
    int? userId,
  }) async {
    final db = await _appDatabase.database;

    await db.update(
      TableNames.offlineBooks,
      {
        'local_file_path': localFilePath,
        'is_downloaded': 1,
        'downloaded_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'user_id = ? AND id = ?',
      whereArgs: [_scope(userId), bookId],
    );
  }
}

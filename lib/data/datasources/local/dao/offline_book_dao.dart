import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';
import 'package:book_reader/data/models/book_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';

class OfflineBookDao {
  final AppDatabase _appDatabase;

  OfflineBookDao(this._appDatabase);

  Future<void> insertOrUpdateBook(BookModel book) async {
    final db = await _appDatabase.database;

    await db.insert(
      TableNames.offlineBooks,
      book.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('===== ĐÃ LƯU SÁCH OFFLINE =====');
    debugPrint('ID: ${book.id}');
    debugPrint('Title: ${book.title}');
    debugPrint('Authors: ${book.authors.join(', ')}');
    debugPrint('Thumbnail: ${book.thumbnailUrl}');
    debugPrint('Local file: ${book.localFilePath}');
    debugPrint('Is downloaded: ${book.isDownloaded}');

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM offline_books'),
    );

    debugPrint('Tổng số sách trong offline_books: $count');
  }

  Future<List<BookModel>> getOfflineBooks() async {
    final db = await _appDatabase.database;

    final maps = await db.query(
      TableNames.offlineBooks,
      where: 'is_downloaded = ?',
      whereArgs: [1],
      orderBy: 'downloaded_at DESC',
    );

    return maps.map((map) => BookModel.fromSqlite((map))).toList();
  }

  Future<BookModel?> getBookById(String bookId) async {
    final db = await _appDatabase.database;

    final maps = await db.query(
      TableNames.offlineBooks,
      where: 'id = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return BookModel.fromSqlite(maps.first);
  }

  Future<void> deleteOfflineBook(String bookId) async {
    final db = await _appDatabase.database;

    await db.delete(
      TableNames.offlineBooks,
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<void> updateDownloadedFilePath({
    required String bookId,
    required String localFilePath,
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
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }
}

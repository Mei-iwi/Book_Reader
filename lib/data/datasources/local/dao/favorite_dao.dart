import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';

class FavoriteDao {
  final AppDatabase _appDatabase;

  FavoriteDao(this._appDatabase);

  int _scope(int? userId) => userId ?? 0;

  Future<void> addFavorite({
    required String bookId,
    required String title,
    String? author,
    String? coverUrl,
    int? userId,
  }) async {
    final db = await _appDatabase.database;
    final existing = await db.query(
      TableNames.favorites,
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [_scope(userId), bookId],
    );

    if (existing.isEmpty) {
      await db.insert(TableNames.favorites, {
        'user_id': _scope(userId),
        'book_id': bookId,
        'title': title,
        'author': author ?? 'Unknown',
        'cover_url': coverUrl ?? '',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> removeFavorite(String bookId, {int? userId}) async {
    final db = await _appDatabase.database;
    await db.delete(
      TableNames.favorites,
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [_scope(userId), bookId],
    );
  }

  Future<bool> isFavorite(String bookId, {int? userId}) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      TableNames.favorites,
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [_scope(userId), bookId],
    );
    return maps.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getAllFavorites({int? userId}) async {
    final db = await _appDatabase.database;
    return await db.query(
      TableNames.favorites,
      where: 'user_id = ?',
      whereArgs: [_scope(userId)],
      orderBy: 'created_at DESC',
    );
  }
}

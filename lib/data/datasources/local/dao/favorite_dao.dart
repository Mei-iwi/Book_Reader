import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';

class FavoriteDao {
  final AppDatabase _appDatabase;

  FavoriteDao(this._appDatabase);

  Future<void> addFavorite({
    required String bookId,
    required String title,
    String? author,
    String? coverUrl,
  }) async {
    final db = await _appDatabase.database;
    final existing = await db.query(
      TableNames.favorites,
      where: 'book_id = ?',
      whereArgs: [bookId],
    );

    if (existing.isEmpty) {
      await db.insert(TableNames.favorites, {
        'book_id': bookId,
        'title': title,
        'author': author ?? 'Unknown',
        'cover_url': coverUrl ?? '',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> removeFavorite(String bookId) async {
    final db = await _appDatabase.database;
    await db.delete(
      TableNames.favorites,
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
  }

  Future<bool> isFavorite(String bookId) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      TableNames.favorites,
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
    return maps.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getAllFavorites() async {
    final db = await _appDatabase.database;
    return await db.query(TableNames.favorites, orderBy: 'created_at DESC');
  }
}

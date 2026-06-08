import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';
import 'package:book_reader/data/models/news_model.dart';
import 'package:sqflite/sqflite.dart';

class NewsLikeDao {
  final AppDatabase _appDatabase;

  NewsLikeDao(this._appDatabase);

  Future<bool> isLiked(String newsId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      TableNames.newsLikes,
      columns: const ['id'],
      where: 'news_id = ?',
      whereArgs: [newsId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Set<String>> getLikedIds() async {
    final db = await _appDatabase.database;
    final rows = await db.query(TableNames.newsLikes, columns: const ['news_id']);
    return rows.map((row) => row['news_id'].toString()).toSet();
  }

  Future<List<Map<String, dynamic>>> getLikedNews() async {
    final db = await _appDatabase.database;
    return db.query(TableNames.newsLikes, orderBy: 'liked_at DESC');
  }

  Future<void> like(NewsModel news) async {
    final db = await _appDatabase.database;
    await db.insert(TableNames.newsLikes, {
      'news_id': news.id,
      'title': news.title,
      'url': news.link,
      'image_url': news.imageUrl,
      'liked_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> unlike(String newsId) async {
    final db = await _appDatabase.database;
    await db.delete(
      TableNames.newsLikes,
      where: 'news_id = ?',
      whereArgs: [newsId],
    );
  }
}

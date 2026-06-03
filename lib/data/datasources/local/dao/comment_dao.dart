import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';

class CommentDao {
  final AppDatabase _appDatabase;

  CommentDao(this._appDatabase);

  Future<void> addComment({
    required String bookId,
    required String userName,
    required String content,
  }) async {
    final db = await _appDatabase.database;
    await db.insert(TableNames.comments, {
      'book_id': bookId,
      'user_name': userName,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getComments(String bookId) async {
    final db = await _appDatabase.database;
    return await db.query(
      TableNames.comments,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'created_at DESC',
    );
  }
}

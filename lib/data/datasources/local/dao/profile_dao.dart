import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/local/tables/table_names.dart';

class ProfileDao {
  final AppDatabase _appDatabase;

  ProfileDao(this._appDatabase);

  Future<void> saveProfile({
    required String id,
    required String fullName,
    required String email,
    String? avatarPath,
  }) async {
    final db = await _appDatabase.database;

    final existing = await db.query(
      TableNames.userProfile,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    final data = {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar_path': avatarPath,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (existing.isEmpty) {
      await db.insert(TableNames.userProfile, data);
    } else {
      await db.update(
        TableNames.userProfile,
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<Map<String, dynamic>?> getProfile(String id) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      TableNames.userProfile,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }
}

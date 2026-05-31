import 'dart:convert';
import 'dart:io';

import 'package:book_reader/data/models/user_model.dart';
import 'package:book_reader/domain/entities/app_user.dart';
import 'package:path_provider/path_provider.dart';

class SessionStorage {
  static const _fileName = 'book_reader_session.json';

  Future<File> _sessionFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> saveUser(AppUser user) async {
    final file = await _sessionFile();
    final data = {
      'userId': user.userId,
      'fullName': user.fullName,
      'email': user.email,
      'role': user.role,
      'token': user.token,
    };

    await file.writeAsString(jsonEncode(data));
  }

  Future<AppUser?> getUser() async {
    final file = await _sessionFile();
    if (!await file.exists()) return null;

    final content = await file.readAsString();
    if (content.trim().isEmpty) return null;

    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) return null;

    return UserModel.fromJson(decoded);
  }

  Future<void> clear() async {
    final file = await _sessionFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}

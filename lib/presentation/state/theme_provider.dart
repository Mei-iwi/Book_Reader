import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ThemeProvider extends ChangeNotifier {
  static const _fileName = 'book_reader_theme.json';

  ThemeMode themeMode = ThemeMode.light;
  bool _loaded = false;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  Future<void> loadTheme() async {
    if (_loaded) return;
    _loaded = true;

    final file = await _themeFile();
    if (!await file.exists()) {
      notifyListeners();
      return;
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      notifyListeners();
      return;
    }

    final decoded = jsonDecode(content);
    if (decoded is Map<String, dynamic> && decoded['isDark'] == true) {
      themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();

    final file = await _themeFile();
    await file.writeAsString(jsonEncode({'isDark': isDarkMode}));
  }

  Future<File> _themeFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}

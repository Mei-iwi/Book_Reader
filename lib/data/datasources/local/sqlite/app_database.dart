import 'package:book_reader/data/datasources/local/tables/table_names.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'book_reader.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE offline_books (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    authors TEXT,
    description TEXT,
    thumbnail_url TEXT,
    categories TEXT,
    page_count INTEGER DEFAULT 0,
    language TEXT,
    preview_link TEXT,
    web_reader_link TEXT,
    source TEXT,
    pdf_download_link TEXT,
    epub_download_link TEXT,
    local_file_path TEXT,
    cover_local_path TEXT,
    is_downloaded INTEGER DEFAULT 0,
    downloaded_at TEXT,
    created_at TEXT,
    updated_at TEXT
  )
''');

    await db.execute('''
    CREATE TABLE reading_progress (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id TEXT NOT NULL,
      current_page INTEGER DEFAULT 0,
      progress_percent REAL DEFAULT 0,
      updated_at TEXT,
      FOREIGN KEY(book_id) REFERENCES offline_books(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id TEXT NOT NULL,
      page INTEGER NOT NULL,
      note TEXT,
      created_at TEXT,
      FOREIGN KEY(book_id) REFERENCES offline_books(id)
    )
  ''');
  }
}

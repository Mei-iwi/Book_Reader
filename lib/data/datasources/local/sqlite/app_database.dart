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

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: _ensureSchema,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _ensureSchema(db);
  }

  Future<void> _ensureSchema(Database db) async {
    await db.execute('''
  CREATE TABLE IF NOT EXISTS offline_books (
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
    CREATE TABLE IF NOT EXISTS reading_progress (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id TEXT NOT NULL,
      current_page INTEGER DEFAULT 0,
      progress_percent REAL DEFAULT 0,
      updated_at TEXT,
      FOREIGN KEY(book_id) REFERENCES offline_books(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id TEXT NOT NULL,
      page INTEGER NOT NULL,
      note TEXT,
      created_at TEXT,
      FOREIGN KEY(book_id) REFERENCES offline_books(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE comments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id TEXT NOT NULL,
      user_name TEXT NOT NULL,
      content TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE user_profile (
      id TEXT PRIMARY KEY,
      full_name TEXT,
      email TEXT,
      avatar_path TEXT,
      updated_at TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE favorites (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id TEXT NOT NULL,
      title TEXT NOT NULL,
      author TEXT,
      cover_url TEXT,
      created_at TEXT NOT NULL
    )
  ''');
  }
}

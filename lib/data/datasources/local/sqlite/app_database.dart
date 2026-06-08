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

    return openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
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
      book_title TEXT,
      cover_url TEXT,
      current_page INTEGER DEFAULT 0,
      total_page INTEGER DEFAULT 1,
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

    await _createV2Tables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await _createV2Tables(db);
    }
  }

  Future<void> _createV2Tables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS news_likes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      news_id TEXT NOT NULL UNIQUE,
      title TEXT NOT NULL,
      url TEXT NOT NULL,
      image_url TEXT,
      liked_at TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS book_reviews (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id TEXT NOT NULL UNIQUE,
      book_title TEXT,
      cover_url TEXT,
      rating REAL NOT NULL,
      content TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

    await _ensureColumn(db, 'reading_progress', 'book_title', 'TEXT');
    await _ensureColumn(db, 'reading_progress', 'cover_url', 'TEXT');
    await _ensureColumn(db, 'reading_progress', 'total_page', 'INTEGER DEFAULT 1');
    await _ensureColumn(db, 'book_reviews', 'book_title', 'TEXT');
    await _ensureColumn(db, 'book_reviews', 'cover_url', 'TEXT');
  }

  Future<void> _ensureColumn(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }
}

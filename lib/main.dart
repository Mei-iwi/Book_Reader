import 'package:book_reader/app.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/datasources/local/dao/offline_book_dao.dart';
import 'package:book_reader/data/datasources/local/file_cache/book_file_downloader.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/remote/api/google_books_api.dart';
import 'package:book_reader/domain/repositories/book_repository_impl.dart';
import 'package:book_reader/presentation/pages/home/home_book_provider.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
import 'package:book_reader/presentation/state/news_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  final apiClient = ApiClient();
  final googleBooksApi = GoogleBooksApi(apiClient);

  final appDatabase = AppDatabase.instance;
  final offlineBookDao = OfflineBookDao(appDatabase);
  final bookFileDownloader = BookFileDownloader();

  final bookRepository = BookRepositoryImpl(
    googleBooksApi,
    offlineBookDao,
    bookFileDownloader,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeBookProvider(bookRepository)),
        ChangeNotifierProvider(create: (context) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider(bookRepository)),
      ],
      child: const Application(),
    ),
  );
}

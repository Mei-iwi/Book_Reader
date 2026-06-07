import 'package:book_reader/app.dart';
import 'package:book_reader/core/services/local_storage/session_storage.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/datasources/local/dao/offline_book_dao.dart';
import 'package:book_reader/data/datasources/local/file_cache/book_file_downloader.dart';
import 'package:book_reader/data/datasources/local/sqlite/app_database.dart';
import 'package:book_reader/data/datasources/remote/api/auth_api.dart';
import 'package:book_reader/data/datasources/remote/api/google_books_api.dart';
import 'package:book_reader/data/datasources/remote/api/gutendex_api.dart';
import 'package:book_reader/data/datasources/remote/api/library_api.dart';
import 'package:book_reader/data/datasources/remote/api/membership_api.dart';
import 'package:book_reader/domain/repositories/auth_repository_impl.dart';
import 'package:book_reader/domain/repositories/book_repository.dart';
import 'package:book_reader/domain/repositories/book_repository_impl.dart';
import 'package:book_reader/domain/usecases/search_books.dart';
import 'package:book_reader/presentation/pages/home/home_book_provider.dart';
import 'package:book_reader/presentation/state/auth_provider.dart';
import 'package:book_reader/presentation/state/book_provider.dart';
import 'package:book_reader/presentation/state/library_provider.dart';
import 'package:book_reader/presentation/state/membership_provider.dart';
import 'package:book_reader/presentation/state/news_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  final apiClient = ApiClient();
  final authApi = AuthApi(apiClient);
  final googleBooksApi = GoogleBooksApi(apiClient);
  final gutendexApi = GutendexApi();
  final libraryApi = LibraryApi(apiClient);
  final membershipApi = MembershipApi(apiClient);
  final sessionStorage = SessionStorage();

  final appDatabase = AppDatabase.instance;
  final offlineBookDao = OfflineBookDao(appDatabase);
  final bookFileDownloader = BookFileDownloader();

  final bookRepository = BookRepositoryImpl(
    googleBooksApi,
    gutendexApi,
    offlineBookDao,
    bookFileDownloader,
  );
  final authRepository = AuthRepositoryImpl(authApi);
  runApp(
    MultiProvider(
      providers: [
        Provider<BookRepository>.value(value: bookRepository),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository, sessionStorage),
        ),
        ChangeNotifierProvider(create: (_) => HomeBookProvider(bookRepository)),
        ChangeNotifierProvider(
          create: (_) => BookProvider(SearchBooks(bookRepository)),
        ),
        ChangeNotifierProvider(create: (context) => NewsProvider()),
        ChangeNotifierProvider(
          create: (_) => LibraryProvider(bookRepository, libraryApi),
        ),
        ChangeNotifierProvider(
          create: (_) => MembershipProvider(membershipApi),
        ),
      ],
      child: const Application(),
    ),
  );
}

import 'package:book_reader/app.dart';
import 'package:book_reader/core/services/http/api_client.dart';
import 'package:book_reader/data/datasources/remote/api/google_books_api.dart';
import 'package:book_reader/domain/repositories/book_repository_impl.dart';
import 'package:book_reader/presentation/pages/home/home_book_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  final apiClient = ApiClient();
  final googleBooksApi = GoogleBooksApi(apiClient);
  final bookRepository = BookRepositoryImpl(googleBooksApi);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeBookProvider(bookRepository)),
      ],
      child: const Application(),
    ),
  );
}

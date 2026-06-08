import 'dart:convert';

import 'package:book_reader/data/datasources/remote/firebase/firebase_auth_rest_datasource.dart';
import 'package:book_reader/data/datasources/remote/firebase/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FirebaseReaderSyncDataSource {
  final FirebaseRemoteConfig _config;
  final FirebaseAuthRestDataSource _authDataSource;

  FirebaseReaderSyncDataSource({
    FirebaseRemoteConfig? config,
    FirebaseAuthRestDataSource? authDataSource,
  }) : _config = config ?? const FirebaseRemoteConfig(),
       _authDataSource =
           authDataSource ?? FirebaseAuthRestDataSource(config: config);

  bool get isEnabled => _config.isConfigured;

  Future<void> saveReadingProgress({
    required int? userId,
    required String bookId,
    required String title,
    required int currentPage,
    required double progressPercent,
  }) async {
    if (!isEnabled || bookId.trim().isEmpty) return;

    final userKey = _userKey(userId);
    final documentPath =
        'users/$userKey/readingProgress/${_safeDocumentId(bookId)}';

    await _patchDocument(
      documentPath,
      {
        'userId': userId,
        'bookId': bookId,
        'title': title,
        'currentPage': currentPage,
        'progressPercent': progressPercent,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      },
      updateMasks: const [
        'userId',
        'bookId',
        'title',
        'currentPage',
        'progressPercent',
        'updatedAt',
      ],
    );
  }

  Future<void> addBookmark({
    required int? userId,
    required String bookId,
    required String title,
    required int page,
    String? note,
  }) async {
    if (!isEnabled || bookId.trim().isEmpty) return;

    final now = DateTime.now().toUtc();
    final userKey = _userKey(userId);
    final bookmarkId = _safeDocumentId(
      '${bookId}_${page}_${now.microsecondsSinceEpoch}',
    );

    await _patchDocument(
      'users/$userKey/bookmarks/$bookmarkId',
      {
        'userId': userId,
        'bookId': bookId,
        'title': title,
        'page': page,
        'note': note ?? '',
        'createdAt': now.toIso8601String(),
      },
      updateMasks: const [
        'userId',
        'bookId',
        'title',
        'page',
        'note',
        'createdAt',
      ],
    );
  }

  Future<void> _patchDocument(
    String documentPath,
    Map<String, Object?> values, {
    required List<String> updateMasks,
  }) async {
    final session = await _authDataSource.signInAnonymously();
    final uri = _config.firestoreDocumentUri(
      documentPath,
      queryParameters: {'updateMask.fieldPaths': updateMasks},
    );

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (session != null) {
      headers['Authorization'] = 'Bearer ${session.idToken}';
    }

    final response = await http
        .patch(
          uri,
          headers: headers,
          body: jsonEncode({'fields': _toFirestoreFields(values)}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        'FIREBASE SYNC ERROR ${response.statusCode}: ${response.body}',
      );
    }
  }

  Map<String, Map<String, Object>> _toFirestoreFields(
    Map<String, Object?> values,
  ) {
    return values.map((key, value) => MapEntry(key, _toFirestoreValue(value)));
  }

  Map<String, Object> _toFirestoreValue(Object? value) {
    if (value == null) return {'nullValue': 'NULL_VALUE'};
    if (value is int) return {'integerValue': value.toString()};
    if (value is double) return {'doubleValue': value};
    if (value is bool) return {'booleanValue': value};
    return {'stringValue': value.toString()};
  }

  String _userKey(int? userId) {
    return userId == null ? 'guest' : 'appUser_$userId';
  }

  String _safeDocumentId(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}

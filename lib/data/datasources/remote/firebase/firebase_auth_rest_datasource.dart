import 'dart:convert';

import 'package:book_reader/data/datasources/remote/firebase/firebase_remote_config.dart';
import 'package:http/http.dart' as http;

class FirebaseAnonymousSession {
  final String idToken;
  final String localId;

  const FirebaseAnonymousSession({
    required this.idToken,
    required this.localId,
  });
}

class FirebaseAuthRestDataSource {
  final FirebaseRemoteConfig _config;
  FirebaseAnonymousSession? _cachedSession;

  FirebaseAuthRestDataSource({FirebaseRemoteConfig? config})
    : _config = config ?? const FirebaseRemoteConfig();

  Future<FirebaseAnonymousSession?> signInAnonymously() async {
    if (!_config.isConfigured) return null;
    if (_cachedSession != null) return _cachedSession;

    final response = await http
        .post(
          _config.identityToolkitUri('accounts:signUp'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'returnSecureToken': true}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final idToken = decoded['idToken']?.toString() ?? '';
    final localId = decoded['localId']?.toString() ?? '';

    if (idToken.isEmpty || localId.isEmpty) return null;

    _cachedSession = FirebaseAnonymousSession(
      idToken: idToken,
      localId: localId,
    );
    return _cachedSession;
  }
}

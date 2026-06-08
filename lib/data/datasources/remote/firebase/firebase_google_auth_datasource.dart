import 'dart:convert';

import 'package:book_reader/data/datasources/remote/firebase/firebase_remote_config.dart';
import 'package:book_reader/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class FirebaseGoogleAuthDataSource {
  final FirebaseRemoteConfig _config;
  GoogleSignIn? _googleSignIn;

  FirebaseGoogleAuthDataSource({FirebaseRemoteConfig? config})
    : _config = config ?? const FirebaseRemoteConfig();

  Future<UserModel> signInWithGoogle() async {
    _validateConfig();

    final googleSignIn = _getGoogleSignIn();
    debugPrint('Firebase Google Auth: open legacy Google account picker');
    final googleUser = await googleSignIn.signIn().timeout(
      const Duration(seconds: 45),
      onTimeout: () => throw Exception(
        'Dang nhap Google qua lau. Hay kiem tra Web OAuth Client ID, SHA-1 debug va Google Play services.',
      ),
    );

    if (googleUser == null) {
      throw Exception('Ban da huy dang nhap Google.');
    }

    debugPrint('Firebase Google Auth: Google account selected');

    final googleAuth = await googleUser.authentication.timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw Exception(
        'Lay Google idToken qua lau. Hay kiem tra OAuth client trong Firebase.',
      ),
    );
    final googleIdToken = googleAuth.idToken;

    if (googleIdToken == null || googleIdToken.trim().isEmpty) {
      throw Exception(
        'Google khong tra ve idToken. Hay kiem tra OAuth client id trong Firebase.',
      );
    }

    debugPrint('Firebase Google Auth: exchange Google token with Firebase');
    return _signInFirebaseWithGoogleToken(
      googleUser: googleUser,
      googleIdToken: googleIdToken,
    );
  }

  Future<void> signOut() async {
    try {
      await _getGoogleSignIn().signOut();
    } catch (_) {
      // Logout app must not fail only because Google SDK cleanup failed.
    }
  }

  GoogleSignIn _getGoogleSignIn() {
    final existing = _googleSignIn;
    if (existing != null) return existing;

    final clientId = _blankToNull(FirebaseRemoteConfig.googleClientId);
    final serverClientId =
        _blankToNull(FirebaseRemoteConfig.googleServerClientId) ?? clientId;

    final googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
      clientId: clientId,
      serverClientId: serverClientId,
    );
    _googleSignIn = googleSignIn;
    return googleSignIn;
  }

  void _validateConfig() {
    if (!_config.isConfigured) {
      throw Exception(
        'Thieu FIREBASE_PROJECT_ID hoac FIREBASE_WEB_API_KEY trong firebase_env.json.',
      );
    }

    final webClientId =
        _blankToNull(FirebaseRemoteConfig.googleServerClientId) ??
        _blankToNull(FirebaseRemoteConfig.googleClientId);

    if (webClientId == null || _looksLikePlaceholder(webClientId)) {
      throw Exception(
        'Thieu FIREBASE_GOOGLE_SERVER_CLIENT_ID. Hay dien Web OAuth Client ID trong firebase_env.json.',
      );
    }

    if (!webClientId.endsWith('.apps.googleusercontent.com')) {
      throw Exception(
        'FIREBASE_GOOGLE_SERVER_CLIENT_ID khong dung dinh dang OAuth Client ID.',
      );
    }
  }

  Future<UserModel> _signInFirebaseWithGoogleToken({
    required GoogleSignInAccount googleUser,
    required String googleIdToken,
  }) async {
    final response = await http
        .post(
          _config.identityToolkitUri('accounts:signInWithIdp'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'postBody': Uri(
              queryParameters: {
                'id_token': googleIdToken,
                'providerId': 'google.com',
              },
            ).query,
            'requestUri': 'http://localhost',
            'returnIdpCredential': true,
            'returnSecureToken': true,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractFirebaseError(decoded, response.statusCode));
    }

    final firebaseIdToken = decoded['idToken']?.toString() ?? '';
    final firebaseLocalId = decoded['localId']?.toString() ?? googleUser.id;
    final email = decoded['email']?.toString() ?? googleUser.email;
    final fullName =
        decoded['displayName']?.toString() ??
        googleUser.displayName ??
        _nameFromEmail(email);
    final avatarUrl =
        decoded['photoUrl']?.toString() ?? googleUser.photoUrl ?? '';

    if (firebaseIdToken.trim().isEmpty || firebaseLocalId.trim().isEmpty) {
      throw Exception('Firebase khong tra ve thong tin dang nhap hop le.');
    }

    return UserModel(
      userId: _stableNegativeUserId(firebaseLocalId),
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
      role: 'firebase',
      token: firebaseIdToken,
    );
  }

  String _extractFirebaseError(Map<String, dynamic> decoded, int statusCode) {
    final error = decoded['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return 'Firebase Auth error: $message';
      }
    }
    return 'Firebase Auth error: $statusCode';
  }

  int _stableNegativeUserId(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    if (hash == 0) return -1;
    return -hash;
  }

  String _nameFromEmail(String email) {
    final name = email.split('@').first.trim();
    return name.isEmpty ? 'Firebase User' : name;
  }

  String? _blankToNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  bool _looksLikePlaceholder(String value) {
    final text = value.toLowerCase();
    return text.contains('your_') || text.contains('replace_me');
  }
}

class FirebaseRemoteConfig {
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String webApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
  );
  static const String databaseId = String.fromEnvironment(
    'FIREBASE_DATABASE_ID',
    defaultValue: '(default)',
  );
  static const String googleClientId = String.fromEnvironment(
    'FIREBASE_GOOGLE_CLIENT_ID',
  );
  static const String googleServerClientId = String.fromEnvironment(
    'FIREBASE_GOOGLE_SERVER_CLIENT_ID',
  );

  const FirebaseRemoteConfig();

  bool get isConfigured {
    return projectId.trim().isNotEmpty && webApiKey.trim().isNotEmpty;
  }

  Uri firestoreDocumentUri(
    String documentPath, {
    Map<String, dynamic>? queryParameters,
  }) {
    return Uri.https(
      'firestore.googleapis.com',
      '/v1/projects/$projectId/databases/$databaseId/documents/$documentPath',
      {'key': webApiKey, ...?queryParameters},
    );
  }

  Uri identityToolkitUri(String endpoint) {
    return Uri.https('identitytoolkit.googleapis.com', '/v1/$endpoint', {
      'key': webApiKey,
    });
  }
}

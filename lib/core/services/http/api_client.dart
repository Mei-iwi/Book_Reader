import 'dart:convert';

import 'package:http/http.dart' as http;

/*
 * Cấu hình http dùng chung 
 */
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(
    String baseUrl,
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse(
      baseUrl,
    ).replace(path: path, queryParameters: queryParameters);

    final respone = await _client.get(uri);

    if (respone.statusCode >= 200 && respone.statusCode < 300) {
      return jsonDecode(respone.body) as Map<String, dynamic>;
    }
    throw Exception('Api erroer: ${respone.statusCode} - ${respone.body}');
  }
}

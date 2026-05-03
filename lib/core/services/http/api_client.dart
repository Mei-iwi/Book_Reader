import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  Future<Map<String, dynamic>> get(
    String baseUrl,
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.https(
      baseUrl.replaceFirst('https://', '').replaceFirst('http://', ''),
      endpoint,
      queryParameters,
    );

    final response = await http.get(
      uri,
      headers: const {
        'X-Android-Package': 'com.example.book_reader',
        'X-Android-Cert': '07E1AE082737C6C13905E706AD8F833C48D5BC84',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Api error: ${response.statusCode} - ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

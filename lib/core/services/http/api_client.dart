import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  String? _token;

  String? get token => _token;

  void setToken(String? token) {
    _token = token;
  }

  Future<dynamic> get(
    String baseUrl,
    String endpoint, {
    Map<String, String>? queryParameters,
    String? bearerToken,
  }) {
    return _send(
      'GET',
      baseUrl,
      endpoint,
      queryParameters: queryParameters,
      bearerToken: bearerToken,
    );
  }

  Future<dynamic> post(
    String baseUrl,
    String endpoint, {
    Map<String, String>? queryParameters,
    Object? body,
    String? bearerToken,
  }) {
    return _send(
      'POST',
      baseUrl,
      endpoint,
      queryParameters: queryParameters,
      body: body,
      bearerToken: bearerToken,
    );
  }

  Future<dynamic> put(
    String baseUrl,
    String endpoint, {
    Map<String, String>? queryParameters,
    Object? body,
    String? bearerToken,
  }) {
    return _send(
      'PUT',
      baseUrl,
      endpoint,
      queryParameters: queryParameters,
      body: body,
      bearerToken: bearerToken,
    );
  }

  Future<dynamic> delete(
    String baseUrl,
    String endpoint, {
    Map<String, String>? queryParameters,
    String? bearerToken,
  }) {
    return _send(
      'DELETE',
      baseUrl,
      endpoint,
      queryParameters: queryParameters,
      bearerToken: bearerToken,
    );
  }

  Future<dynamic> _send(
    String method,
    String baseUrl,
    String endpoint, {
    Map<String, String>? queryParameters,
    Object? body,
    String? bearerToken,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ).replace(queryParameters: queryParameters);
    debugPrint('API $method $uri');

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final token = bearerToken ?? _token;
    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final encodedBody = body == null ? null : jsonEncode(body);
    late final http.Response response;

    try {
      response = await (switch (method) {
        'POST' => http.post(uri, headers: headers, body: encodedBody),
        'PUT' => http.put(uri, headers: headers, body: encodedBody),
        'DELETE' => http.delete(uri, headers: headers),
        _ => http.get(uri, headers: headers),
      }).timeout(const Duration(seconds: 20));
    } on SocketException {
      throw Exception('Không thể kết nối backend. Hãy kiểm tra mạng hoặc server.');
    } on HttpException {
      throw Exception('Lỗi HTTP khi gọi backend.');
    } on FormatException {
      throw Exception('Dữ liệu backend trả về không hợp lệ.');
    }

    final decoded = response.body.trim().isEmpty
        ? null
        : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(decoded, response.statusCode));
    }

    return _unwrapApiResponse(decoded);
  }

  dynamic _unwrapApiResponse(dynamic decoded) {
    if (decoded is Map<String, dynamic> && decoded.containsKey('success')) {
      if (decoded['success'] != true) {
        throw Exception(decoded['message']?.toString() ?? 'Request failed');
      }
      return decoded['data'];
    }

    return decoded;
  }

  String _extractMessage(dynamic decoded, int statusCode) {
    if (decoded is Map<String, dynamic>) {
      return decoded['message']?.toString() ??
          decoded['title']?.toString() ??
          'Api error: $statusCode';
    }
    return 'Api error: $statusCode';
  }
}

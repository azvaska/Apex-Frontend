import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:apex/shared/api/api_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final http.Client _client;
  final String _baseUrl;
  final Future<String?> Function()? _tokenProvider;

  ApiClient({
    http.Client? client,
    String? baseUrl,
    Future<String?> Function()? tokenProvider,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _tokenProvider = tokenProvider ?? _firebaseTokenProvider;

  Future<dynamic> getJson(
    String path, {
    Map<String, String>? query,
  }) {
    return _request('GET', path, query: query);
  }

  Future<dynamic> postJson(
    String path, {
    Object? body,
  }) {
    return _request('POST', path, body: body);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query);
    final headers = await _buildHeaders();
    http.Response response;
    switch (method) {
      case 'POST':
        response = await _client.post(uri, headers: headers, body: _encode(body));
        break;
      case 'GET':
      default:
        response = await _client.get(uri, headers: headers);
        break;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }

    if (response.body.isEmpty) {
      return null;
    }
    return jsonDecode(response.body);
  }

  Uri _buildUri(String path, Map<String, String>? query) {
    final trimmedBase = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final trimmedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$trimmedBase$trimmedPath').replace(
      queryParameters: query,
    );
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final token = await _tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  String? _encode(Object? body) {
    if (body == null) {
      return null;
    }
    return jsonEncode(body);
  }

  static Future<String?> _firebaseTokenProvider() async {
    try {
      return await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (_) {
      return null;
    }
  }
}

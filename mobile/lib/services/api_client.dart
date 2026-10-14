import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl, this.deviceId})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? 'http://localhost:8080';

  final http.Client _client;
  final String baseUrl;
  String? deviceId;
  String? token;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers({
    bool jsonBody = false,
    bool auth = true,
    bool includeDeviceId = false,
  }) {
    final headers = <String, String>{};
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (auth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (includeDeviceId && deviceId != null && deviceId!.isNotEmpty) {
      headers['X-Device-Id'] = deviceId!;
    }
    return headers;
  }

  Future<T> request<T>(
    String method,
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? parser,
    bool auth = true,
    bool includeDeviceId = false,
  }) async {
    final headers = _headers(
      jsonBody: body != null,
      auth: auth,
      includeDeviceId: includeDeviceId,
    );
    final uri = _uri(path);
    final encoded = body == null ? null : jsonEncode(body);

    late http.Response response;
    switch (method) {
      case 'GET':
        response = await _client.get(uri, headers: headers);
      case 'POST':
        response = await _client.post(uri, headers: headers, body: encoded);
      case 'PUT':
        response = await _client.put(uri, headers: headers, body: encoded);
      case 'DELETE':
        response = await _client.delete(uri, headers: headers);
      default:
        throw ApiException('Unsupported method $method');
    }

    if (response.statusCode >= 400) {
      String message = 'Request failed (${response.statusCode})';
      try {
        final json = jsonDecode(response.body);
        if (json is Map && json['error'] != null) {
          message = json['error'].toString();
        }
      } catch (_) {}
      throw ApiException(message);
    }

    if (response.body.isEmpty || response.statusCode == 204) {
      return parser != null ? parser(null) : null as T;
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    return parser != null ? parser(json) : json as T;
  }
}

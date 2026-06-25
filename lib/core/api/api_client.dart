import 'dart:convert';

import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    TokenStorage? tokenStorage,
    String? baseUrl,
  }) : _httpClient = httpClient ?? http.Client(),
       _tokenStorage = tokenStorage ?? TokenStorage(),
       _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _httpClient;
  final TokenStorage _tokenStorage;
  final String _baseUrl;

  Future<T> get<T>(
    String path,
    T Function(Object? json) fromJson, {
    bool authorized = false,
  }) async {
    final response = await _send('GET', path, authorized: authorized);
    return fromJson(_decode(response));
  }

  Future<T> post<T>(
    String path,
    Object? body,
    T Function(Object? json) fromJson, {
    bool authorized = false,
  }) async {
    final response = await _send(
      'POST',
      path,
      body: body,
      authorized: authorized,
    );
    return fromJson(_decode(response));
  }

  Future<T> put<T>(
    String path,
    Object? body,
    T Function(Object? json) fromJson, {
    bool authorized = false,
  }) async {
    final response = await _send(
      'PUT',
      path,
      body: body,
      authorized: authorized,
    );
    return fromJson(_decode(response));
  }

  Future<T> patch<T>(
    String path,
    Object? body,
    T Function(Object? json) fromJson, {
    bool authorized = false,
  }) async {
    final response = await _send(
      'PATCH',
      path,
      body: body,
      authorized: authorized,
    );
    return fromJson(_decode(response));
  }

  Future<void> delete(String path, {bool authorized = false}) async {
    await _send('DELETE', path, authorized: authorized);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Object? body,
    bool authorized = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };

    if (authorized) {
      final token = await _tokenStorage.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final encodedBody = body == null ? null : jsonEncode(body);
    final response = switch (method) {
      'GET' => await _httpClient.get(uri, headers: headers),
      'POST' => await _httpClient.post(
        uri,
        headers: headers,
        body: encodedBody,
      ),
      'PUT' => await _httpClient.put(uri, headers: headers, body: encodedBody),
      'PATCH' => await _httpClient.patch(
        uri,
        headers: headers,
        body: encodedBody,
      ),
      'DELETE' => await _httpClient.delete(uri, headers: headers),
      _ => throw ArgumentError.value(method, 'method', 'Unsupported method'),
    };

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _toApiException(response);
    }

    return response;
  }

  Object? _decode(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  ApiException _toApiException(http.Response response) {
    Object? details;
    var message = response.reasonPhrase ?? 'Request failed';

    if (response.body.isNotEmpty) {
      try {
        details = jsonDecode(response.body);
        if (details is Map<String, dynamic>) {
          message =
              details['title']?.toString() ??
              details['message']?.toString() ??
              details['error']?.toString() ??
              message;
        } else if (details is List) {
          final errors = details.map((e) {
            if (e is Map<String, dynamic>) {
              return e['description']?.toString() ?? e['message']?.toString() ?? '';
            }
            return e.toString();
          }).where((msg) => msg.isNotEmpty).join('\n');
          if (errors.isNotEmpty) {
            message = errors;
          }
        } else if (details is String) {
          message = details;
        }
      } catch (_) {
        message = response.body;
      }
    }

    return ApiException(
      message,
      statusCode: response.statusCode,
      details: details,
    );
  }
}

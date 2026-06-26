import 'dart:convert';

import 'package:deca_mobile/core/config/app_config.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/storage/token_storage.dart';
import 'package:http/http.dart' as http;

/// Facade quanh [http.Client]: gan Bearer token, boc vo {success,data,error}
/// tra ve phan `data` tho, va anh xa HTTP status -> [ApiException].
///
/// Repository chi phu thuoc class nay, khong dung `http` truc tiep.
class ApiClient {
  ApiClient({
    required this.config,
    required this.tokenStorage,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final AppConfig config;
  final TokenStorage tokenStorage;
  final http.Client _client;

  /// Hook xu ly 401 toan cuc (AuthCubit gan) — Strategy pattern.
  void Function()? onUnauthorized;

  Future<Object?> get(String path, {Map<String, dynamic>? query}) =>
      _send('GET', path, query: query);

  Future<Object?> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  Future<Object?> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<Object?> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body);

  Future<Object?> delete(String path, {Object? body}) =>
      _send('DELETE', path, body: body);

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final token = await tokenStorage.readAccess();
    final uri = Uri.parse('${config.baseUrl}$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, '$v')),
    );
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final encoded = body == null ? null : jsonEncode(body);

    final http.Response res;
    try {
      res = await _dispatch(method, uri, headers, encoded);
    } on ApiException {
      rethrow;
    } on Object catch (_) {
      throw const NetworkException();
    }
    return _handle(res);
  }

  Future<http.Response> _dispatch(
    String method,
    Uri uri,
    Map<String, String> headers,
    String? body,
  ) {
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: body);
      case 'PUT':
        return _client.put(uri, headers: headers, body: body);
      case 'PATCH':
        return _client.patch(uri, headers: headers, body: body);
      case 'DELETE':
        return _client.delete(uri, headers: headers, body: body);
      default:
        throw ArgumentError('Unsupported method: $method');
    }
  }

  Object? _handle(http.Response res) {
    if (res.statusCode == 401) {
      onUnauthorized?.call();
      throw const UnauthorizedException();
    }

    final decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    final json =
        decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    final ok = res.statusCode >= 200 &&
        res.statusCode < 300 &&
        json['success'] == true;
    if (ok) {
      return json['data'];
    }

    final error = json['error'] as Map<String, dynamic>?;
    final message = error?['message'] as String? ?? 'Đã có lỗi xảy ra';
    if (res.statusCode >= 500) {
      throw ServerException(message);
    }
    throw BusinessException(message, code: error?['code'] as String?);
  }
}

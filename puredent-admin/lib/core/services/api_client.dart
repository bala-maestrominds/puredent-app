import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Thrown for any non-2xx response. Carries the server's error message
/// (backend's ApiError/errorHandler always responds with `{ error: "..." }`).
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

/// Thin wrapper around package:http that:
///  - prefixes requests with the backend's base URL
///  - attaches the admin's bearer token (persisted via SharedPreferences)
///  - decodes JSON responses and surfaces backend error messages
///  - offers a multipart helper for photo/image uploads
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _tokenKey = 'admin_access_token';

  String? _accessToken;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);
  }

  Future<void> setToken(String? token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  Map<String, String> _headers({bool json = true}) {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    if (_accessToken != null) headers['Authorization'] = 'Bearer $_accessToken';
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final url = '${ApiConfig.apiUrl}$cleanPath';
    if (query == null || query.isEmpty) return Uri.parse(url);
    final filtered = query.map((k, v) => MapEntry(k, v?.toString() ?? ''))
      ..removeWhere((k, v) => v.isEmpty);
    return Uri.parse(
      url,
    ).replace(queryParameters: filtered.isEmpty ? null : filtered);
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }

  dynamic _handle(http.Response response) {
    final decoded = _decode(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map && decoded.containsKey('data')) return decoded['data'];
      return decoded;
    }

    String message = 'Something went wrong (${response.statusCode})';
    if (decoded is Map) {
      if (decoded['error'] is String) {
        message = decoded['error'];
      } else if (decoded['message'] is String) {
        message = decoded['message'];
      } else if (decoded['error'] is Map &&
          decoded['error']['message'] is String) {
        message = decoded['error']['message'];
      }
    }
    throw ApiException(response.statusCode, message);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final response = await http.get(_uri(path, query), headers: _headers());
    return _handle(response);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final response = await http.post(
      _uri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _handle(response);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final response = await http.patch(
      _uri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _handle(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(_uri(path), headers: _headers());
    return _handle(response);
  }

  /// Multipart POST/PATCH, used for endpoints that accept a file field
  /// (doctor photo, service image) alongside regular text fields.
  Future<dynamic> multipart(
    String path, {
    required String method, // 'POST' or 'PATCH'
    required Map<String, String> fields,
    String? fileField,
    String? filePath,
  }) async {
    final request = http.MultipartRequest(method, _uri(path));
    if (_accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    request.fields.addAll(fields);

    if (fileField != null && filePath != null) {
      // image_picker's cache files on Android/iOS often lack a proper file
      // extension, so http's automatic content-type guessing falls back to
      // application/octet-stream. The backend's multer filter only accepts
      // image/* mimetypes and rejects anything else with a generic 500,
      // which is why "Add Dentist" failed whenever a photo was attached but
      // worked fine without one. Detect the mime type explicitly (falling
      // back to image/jpeg, since this field is only ever used for photos).
      final mimeType = lookupMimeType(filePath) ?? 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          fileField,
          filePath,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _handle(response);
  }

  /// Resolves a possibly-relative URL (e.g. `/uploads/xyz.jpg`) returned by
  /// the backend into an absolute one the app can load directly.
  static String resolveMediaUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final path = url.startsWith('/') ? url : '/$url';
    return '${ApiConfig.baseUrl}$path';
  }
}

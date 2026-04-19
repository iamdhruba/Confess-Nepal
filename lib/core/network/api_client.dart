import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // Set via --dart-define=BASE_URL=https://your-app.onrender.com/api at build time
  // Defaults: web=localhost, Android emulator=10.0.2.2
  static String get _baseUrl {
    const defined = String.fromEnvironment('BASE_URL', defaultValue: 'https://confess-nepal.onrender.com/api');
    if (defined.isNotEmpty) return defined;
    if (kIsWeb) return 'http://localhost:5000/api';
    return 'http://10.0.2.2:5000/api';
  }
  static const String _tokenKey = 'auth_token';

  // Lazy — not constructed until first use, avoids platform channel crash
  FlutterSecureStorage get _secureStorage => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  String? _token;

  Future<void> init() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
    } else {
      _token = await _secureStorage.read(key: _tokenKey);
    }
  }

  Future<void> saveToken(String token) async {
    _token = token;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } else {
      await _secureStorage.write(key: _tokenKey, value: token);
    }
  }

  Future<void> clearToken() async {
    _token = null;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } else {
      await _secureStorage.delete(key: _tokenKey);
    }
  }

  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static const _timeout = Duration(seconds: 15);

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final response = await http.get(uri, headers: _headers).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http
        .post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http
        .patch(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response =
        await http.delete(uri, headers: _headers).timeout(_timeout);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      body['message'] ?? 'Something went wrong',
      statusCode: response.statusCode,
    );
  }
}

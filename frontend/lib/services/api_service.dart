import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  ApiException(this.statusCode, this.message, {this.errors});

  @override
  String toString() => message;
}

class ApiService {
  static String get baseUrl {
    // Current Local IP Address for physical device testing
    const String ipAddress = '192.168.1.128';

    if (kIsWeb) {
      return 'http://localhost:3000/api/v1'; // Localhost still works for web
    }
    // Android physical device or emulator on local network
    if (Platform.isAndroid) {
      return 'http://$ipAddress:3000/api/v1';
    }
    // iOS physical device or simulator
    return 'http://$ipAddress:3000/api/v1';
  }

  static String? _token;

  /// Load saved token from SharedPreferences
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  /// Save token to SharedPreferences
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Clear token (logout)
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Check if user has a saved token
  static bool get hasToken => _token != null && _token!.isNotEmpty;

  /// Common headers
  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// Parse API response — returns data on success, throws ApiException on error
  static dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      response.statusCode,
      body['message'] ?? 'Terjadi kesalahan',
      errors: body['errors'] is Map ? Map<String, dynamic>.from(body['errors']) : null,
    );
  }

  /// GET request
  static Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  /// POST request
  static Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// PUT request
  static Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.put(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// PATCH request
  static Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.patch(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// DELETE request
  static Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(uri, headers: _headers);
    return _handleResponse(response);
  }
}

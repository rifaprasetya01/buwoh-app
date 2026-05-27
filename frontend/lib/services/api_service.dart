import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.tokenKey);
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await getHeaders();
    debugPrint('API POST: $url');
    debugPrint('Headers: $headers');
    debugPrint('Body: ${jsonEncode(body)}');
    
    try {
      final response = await http.post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('API Error: $e');
      rethrow;
    }
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await getHeaders();
    debugPrint('API GET: $url');
    
    try {
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 10));
      debugPrint('Response Status: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('API Error (GET): $e');
      rethrow;
    }
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await getHeaders();
    debugPrint('API PUT: $url');
    
    try {
      final response = await http.put(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      debugPrint('Response Status: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('API Error (PUT): $e');
      rethrow;
    }
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await getHeaders();
    debugPrint('API PATCH: $url');
    
    try {
      final response = await http.patch(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      debugPrint('Response Status: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('API Error (PATCH): $e');
      rethrow;
    }
  }

  static Future<http.StreamedResponse> multipartPost(
    String endpoint, 
    Map<String, String> fields, 
    Map<String, File> files
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final token = await getToken();
    
    debugPrint('API MULTIPART POST: $url');
    debugPrint('Fields: $fields');
    debugPrint('Files: ${files.keys.toList()}');

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      if (token != null) 'Authorization': 'Bearer $token',
    });
    
    request.fields.addAll(fields);
    
    for (var entry in files.entries) {
      final file = entry.value;
      String filename = file.path.split('/').last;
      
      // Ensure the filename has an image extension for Multer
      final lowerName = filename.toLowerCase();
      if (!lowerName.endsWith('.jpg') && !lowerName.endsWith('.jpeg') && !lowerName.endsWith('.png')) {
        filename = '$filename.jpg';
      }

      final multipartFile = await http.MultipartFile.fromPath(
        entry.key, 
        file.path,
        filename: filename
      );
      request.files.add(multipartFile);
    }
    
    try {
      return await request.send().timeout(const Duration(seconds: 30));
    } catch (e) {
      debugPrint('API Error (Multipart): $e');
      rethrow;
    }
  }

  static Future<http.StreamedResponse> multipartPut(
    String endpoint, 
    Map<String, String> fields, 
    Map<String, File> files
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final token = await getToken();
    
    debugPrint('API MULTIPART PUT: $url');
    debugPrint('Fields: $fields');
    debugPrint('Files: ${files.keys.toList()}');

    final request = http.MultipartRequest('PUT', url);
    request.headers.addAll({
      if (token != null) 'Authorization': 'Bearer $token',
    });
    
    request.fields.addAll(fields);
    
    for (var entry in files.entries) {
      final file = entry.value;
      String filename = file.path.split('/').last;
      
      // Ensure the filename has an image extension for Multer
      final lowerName = filename.toLowerCase();
      if (!lowerName.endsWith('.jpg') && !lowerName.endsWith('.jpeg') && !lowerName.endsWith('.png')) {
        filename = '$filename.jpg';
      }

      final multipartFile = await http.MultipartFile.fromPath(
        entry.key, 
        file.path,
        filename: filename
      );
      request.files.add(multipartFile);
    }
    
    try {
      return await request.send().timeout(const Duration(seconds: 30));
    } catch (e) {
      debugPrint('API Error (Multipart PUT): $e');
      rethrow;
    }
  }
}

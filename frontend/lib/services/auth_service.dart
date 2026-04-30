import 'api_service.dart';

class AuthService {
  /// Login — returns { user, token }
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    final data = response['data'];
    // Save token
    await ApiService.saveToken(data['token']);
    return data;
  }

  /// Register — returns { user, token }
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? address,
    String? phoneNumber,
    DateTime? birthDate,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
    };
    if (address != null && address.isNotEmpty) body['address'] = address;
    if (phoneNumber != null && phoneNumber.isNotEmpty) body['phoneNumber'] = phoneNumber;
    if (birthDate != null) body['birthDate'] = birthDate.toIso8601String().split('T')[0];

    final response = await ApiService.post('/auth/register', body: body);
    final data = response['data'];
    // Save token
    await ApiService.saveToken(data['token']);
    return data;
  }

  /// Get current user profile
  static Future<Map<String, dynamic>> getMe() async {
    final response = await ApiService.get('/auth/me');
    return Map<String, dynamic>.from(response['data']);
  }

  /// Logout — clear token
  static Future<void> logout() async {
    await ApiService.clearToken();
  }
}

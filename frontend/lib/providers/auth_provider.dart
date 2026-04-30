import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;

  String get userName => _user?['name'] ?? 'User';
  String get userAddress => _user?['address'] ?? '';
  String? get userPhotoUrl => _user?['profilePhotoUrl'];

  /// Try to restore session from saved token
  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.loadToken();
      if (!ApiService.hasToken) {
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate token by calling /auth/me
      _user = await AuthService.getMe();
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Token expired or invalid
      await ApiService.clearToken();
      _user = null;
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await AuthService.login(email, password);
      _user = Map<String, dynamic>.from(data['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? address,
    DateTime? birthDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await AuthService.register(
        name: name,
        email: email,
        password: password,
        address: address,
        birthDate: birthDate,
      );
      _user = Map<String, dynamic>.from(data['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

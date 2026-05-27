import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  int _activeDashboardIndex = 0;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _user != null;
  int get activeDashboardIndex => _activeDashboardIndex;

  void setActiveDashboardIndex(int index) {
    _activeDashboardIndex = index;
    notifyListeners();
  }

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(ApiConfig.tokenKey);
    final userData = prefs.getString(ApiConfig.userKey);
    if (userData != null) {
      _user = UserModel.fromJson(jsonDecode(userData));
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = UserModel.fromJson(data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ApiConfig.tokenKey, _token!);
        await prefs.setString(ApiConfig.userKey, jsonEncode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password, String confirmPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = UserModel.fromJson(data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ApiConfig.tokenKey, _token!);
        await prefs.setString(ApiConfig.userKey, jsonEncode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Fetching profile from: /user/profile');
      final response = await ApiService.get('/user/profile');
      debugPrint('Profile API response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Profile API response: $data');
        _user = UserModel.fromJson(data);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ApiConfig.userKey, jsonEncode(_user!.toJson()));
      }
    } catch (e) {
      debugPrint('Fetch profile error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? birthDate,
    String? street,
    String? rtRw,
    String? village,
    String? district,
    String? city,
    String? province,
    String? postalCode,
    double? latitude,
    double? longitude,
    File? photo,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, String> fields = {};
      if (name != null) fields['name'] = name;
      if (birthDate != null) fields['birthDate'] = birthDate;
      
      if (street != null) fields['address[street]'] = street;
      if (rtRw != null) fields['address[rtRw]'] = rtRw;
      if (village != null) fields['address[village]'] = village;
      if (district != null) fields['address[district]'] = district;
      if (city != null) fields['address[city]'] = city;
      if (province != null) fields['address[province]'] = province;
      if (postalCode != null) fields['address[postalCode]'] = postalCode;
      if (latitude != null) fields['address[latitude]'] = latitude.toString();
      if (longitude != null) fields['address[longitude]'] = longitude.toString();

      final Map<String, File> files = {};
      if (photo != null) {
        files['photo'] = photo;
      }

      final streamedResponse = await ApiService.multipartPut('/user/profile', fields, files);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = UserModel.fromJson(data['user']);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ApiConfig.userKey, jsonEncode(data['user']));
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('Update profile failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
    await prefs.remove(ApiConfig.userKey);
    _token = null;
    _user = null;
    notifyListeners();
  }
}

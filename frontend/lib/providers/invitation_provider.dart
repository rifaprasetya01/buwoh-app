import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/invitation_model.dart';
import '../services/api_service.dart';

class InvitationProvider with ChangeNotifier {
  List<InvitationModel> _invitations = [];
  List<InvitationModel> _searchResults = [];
  bool _isLoading = false;
  bool _isSearchLoading = false;

  List<InvitationModel> get invitations => _invitations;
  List<InvitationModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearchLoading => _isSearchLoading;

  Future<void> fetchInvitations({String? search, String? type}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String endpoint = '/invitations';
      List<String> params = [];
      if (search != null) params.add('search=$search');
      if (type != null && type != 'Semua') params.add('type=$type');
      
      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'];
        _invitations = list.map((json) => InvitationModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch invitations error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchInvitations(String search) async {
    _isSearchLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/invitations?search=$search');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'];
        _searchResults = list.map((json) => InvitationModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Search invitations error: $e');
    }

    _isSearchLoading = false;
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  Future<bool> submitBuwoh(String eventId, List<Map<String, dynamic>> contributions) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/invitations/$eventId/buwoh', {
        'contributions': contributions,
      });

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Submit buwoh error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<Map<String, dynamic>?> getMyBuwoh(String eventId) async {
    try {
      final response = await ApiService.get('/invitations/$eventId/my-buwoh');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get my buwoh error: $e');
    }
    return null;
  }

  Future<bool> updateBuwoh(String eventId, List<Map<String, dynamic>> contributions) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.put('/invitations/$eventId/buwoh', {
        'contributions': contributions,
      });

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Update buwoh error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}

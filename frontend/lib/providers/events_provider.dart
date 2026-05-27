import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../services/api_service.dart';

class EventsProvider with ChangeNotifier {
  List<EventModel> _hostedEvents = [];
  List<EventModel> _returnFavorEvents = [];
  bool _isLoading = false;

  List<EventModel> get hostedEvents => _hostedEvents;
  List<EventModel> get returnFavorEvents => _returnFavorEvents;
  bool get isLoading => _isLoading;

  Future<void> fetchHostedEvents({String? status}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final endpoint = status != null ? '/events?status=$status' : '/events';
      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> eventsJson = data['data'];
        _hostedEvents = eventsJson.map((json) => EventModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch events error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchReturnFavorEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/events/return-favor');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> eventsJson = data['data'];
        _returnFavorEvents = eventsJson.map((json) => EventModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch return favor events error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createEvent({
    required String title,
    required String type,
    required String date,
    required String startTime,
    required String endTime,
    required String locationName,
    String? mapLink,
    required String description,
    required List<String> expectedContributions,
    File? coverImage,
  }) async {
    debugPrint('--- PROVIDER: createEvent called ---');
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, String> fields = {
        'title': title,
        'type': type,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'locationName': locationName,
        'description': description,
        'expectedContributions': jsonEncode(expectedContributions),
      };

      if (mapLink != null && mapLink.isNotEmpty) {
        fields['mapLink'] = mapLink;
      }

      final Map<String, File> files = {};
      if (coverImage != null) {
        debugPrint('Cover Image path: ${coverImage.path}');
        files['coverImage'] = coverImage;
      }

      debugPrint('Sending request to ApiService: /events');
      final streamedResponse = await ApiService.multipartPost('/events', fields, files);
      debugPrint('Streamed Response Received. Status: ${streamedResponse.statusCode}');
      
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        await fetchHostedEvents(); // Refresh list
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Create event error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<List<Map<String, dynamic>>> fetchEventGuests(String eventId) async {
    try {
      final response = await ApiService.get('/events/$eventId/guests');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> guestsJson = data['data'];
        return List<Map<String, dynamic>>.from(guestsJson);
      }
    } catch (e) {
      debugPrint('Fetch event guests error: $e');
    }
    return [];
  }

  Future<bool> updateGuestStatus(String eventId, String guestId, String status) async {
    try {
      final response = await ApiService.patch('/events/$eventId/guests/$guestId/status', {
        'status': status,
      });
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('Update guest status error: $e');
    }
    return false;
  }

  Future<bool> addManualGuest(String eventId, String email, List<Map<String, dynamic>> contributions) async {
    try {
      final response = await ApiService.post('/events/$eventId/guests', {
        'email': email,
        'contributions': contributions,
      });
      if (response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint('Add manual guest error: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> fetchEventRecap(String eventId) async {
    try {
      final response = await ApiService.get('/events/$eventId/recap');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Fetch event recap error: $e');
    }
    return null;
  }
}

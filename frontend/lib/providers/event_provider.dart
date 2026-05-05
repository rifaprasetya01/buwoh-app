import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;

  List<EventModel> _upcomingEvents = [];
  bool _isUpcomingLoading = false;
  String? _upcomingError;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<EventModel> get upcomingEvents => _upcomingEvents;
  bool get isUpcomingLoading => _isUpcomingLoading;
  String? get upcomingError => _upcomingError;

  Future<void> fetchEvents({String? query, String? categoryId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await EventService.getPublicEvents(query: query, categoryId: categoryId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUpcomingEvents() async {
    _isUpcomingLoading = true;
    _upcomingError = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi dinonaktifkan.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen. Silakan ubah di pengaturan.');
      }

      Position position = await Geolocator.getCurrentPosition();

      _upcomingEvents = await EventService.getPublicEvents(
        upcoming: true,
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (e) {
      _upcomingError = e.toString();
    } finally {
      _isUpcomingLoading = false;
      notifyListeners();
    }
  }
}

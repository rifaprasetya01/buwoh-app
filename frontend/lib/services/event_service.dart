import '../models/event_model.dart';
import 'api_service.dart';

class EventService {
  /// Mendapatkan daftar semua acara publik (published)
  static Future<List<EventModel>> getPublicEvents({String? query, String? categoryId, double? lat, double? lng, bool? upcoming}) async {
    final queryParams = <String, String>{};
    if (query != null && query.isNotEmpty) {
      queryParams['search'] = query;
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }
    if (lat != null) {
      queryParams['lat'] = lat.toString();
    }
    if (lng != null) {
      queryParams['lng'] = lng.toString();
    }
    if (upcoming != null) {
      queryParams['upcoming'] = upcoming.toString();
    }

    try {
      final response = await ApiService.get('/events', queryParams: queryParams);
      
      // Response format: { success: true, message: ..., data: [...], pagination: {...} }
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];

      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Membuat acara baru
  static Future<void> createEvent({
    required int eventCategoryId,
    required String title,
    String? description,
    required String locationName,
    required String locationAddress,
    required DateTime startDatetime,
    required DateTime endDatetime,
    List<Map<String, dynamic>>? giftRecommendations,
  }) async {
    try {
      await ApiService.post('/events', body: {
        'eventCategoryId': eventCategoryId,
        'title': title,
        'description': description,
        'locationName': locationName,
        'locationAddress': locationAddress,
        'startDatetime': startDatetime.toIso8601String(),
        'endDatetime': endDatetime.toIso8601String(),
        if (giftRecommendations != null) 'giftRecommendations': giftRecommendations,
      });
    } catch (e) {
      rethrow;
    }
  }
}

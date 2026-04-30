import 'api_service.dart';

class EventService {
  /// List public events (published)
  static Future<Map<String, dynamic>> listPublicEvents({
    int page = 1,
    int limit = 10,
    String? search,
    int? categoryId,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null) params['categoryId'] = categoryId.toString();

    final response = await ApiService.get('/events', queryParams: params);
    return {
      'events': List<Map<String, dynamic>>.from(
        (response['data'] as List).map((e) => Map<String, dynamic>.from(e)),
      ),
      'pagination': Map<String, dynamic>.from(response['pagination'] ?? {}),
    };
  }

  /// Get event detail by ID
  static Future<Map<String, dynamic>> getEventById(String eventId) async {
    final response = await ApiService.get('/events/$eventId');
    return Map<String, dynamic>.from(response['data']);
  }

  /// Create new event
  static Future<Map<String, dynamic>> createEvent({
    required int eventCategoryId,
    required String title,
    String? description,
    required String locationName,
    required String locationAddress,
    required DateTime startDatetime,
    required DateTime endDatetime,
    int? maxGuests,
    List<Map<String, dynamic>>? giftRecommendations,
  }) async {
    final body = <String, dynamic>{
      'eventCategoryId': eventCategoryId,
      'title': title,
      'locationName': locationName,
      'locationAddress': locationAddress,
      'startDatetime': startDatetime.toIso8601String(),
      'endDatetime': endDatetime.toIso8601String(),
    };
    if (description != null && description.isNotEmpty) body['description'] = description;
    if (maxGuests != null) body['maxGuests'] = maxGuests;
    if (giftRecommendations != null && giftRecommendations.isNotEmpty) {
      body['giftRecommendations'] = giftRecommendations;
    }

    final response = await ApiService.post('/events', body: body);
    return Map<String, dynamic>.from(response['data']);
  }

  /// List event categories
  static Future<List<Map<String, dynamic>>> listEventCategories() async {
    final response = await ApiService.get('/event-categories');
    return List<Map<String, dynamic>>.from(
      (response['data'] as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  /// List gift categories
  static Future<List<Map<String, dynamic>>> listGiftCategories() async {
    final response = await ApiService.get('/gift-categories');
    return List<Map<String, dynamic>>.from(
      (response['data'] as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  /// Update event status (publish, etc.)
  static Future<Map<String, dynamic>> updateEventStatus(String eventId, String status) async {
    final response = await ApiService.patch('/events/$eventId/status', body: {
      'status': status,
    });
    return Map<String, dynamic>.from(response['data']);
  }
}

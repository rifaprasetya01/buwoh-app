import 'api_service.dart';

class BuwohService {
  /// Apply as guest (Ajukan Buwoh) with gift selections
  static Future<Map<String, dynamic>> applyAsGuest({
    required String eventId,
    required List<Map<String, dynamic>> gifts,
    String? notesFromGuest,
  }) async {
    final body = <String, dynamic>{
      'gifts': gifts,
    };
    if (notesFromGuest != null && notesFromGuest.isNotEmpty) {
      body['notesFromGuest'] = notesFromGuest;
    }

    final response = await ApiService.post('/events/$eventId/guests', body: body);
    return Map<String, dynamic>.from(response['data']);
  }
}

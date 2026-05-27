import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/history_model.dart';
import '../services/api_service.dart';

class HistoryProvider with ChangeNotifier {
  List<HistoryModel> _historyItems = [];
  bool _isLoading = false;

  List<HistoryModel> get historyItems => _historyItems;
  bool get isLoading => _isLoading;

  Future<void> fetchHistory({String? filter}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String endpoint = '/history';
      if (filter != null && filter != 'Semua') {
        endpoint += '?filter=$filter';
      }

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'];
        _historyItems = list.map((json) => HistoryModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch history error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}

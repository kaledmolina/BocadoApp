import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/table_model.dart';

class TablesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<TableModel> _tables = [];
  bool _isLoading = false;

  List<TableModel> get tables => _tables;
  bool get isLoading => _isLoading;

  Future<void> fetchTables() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/tables');
      if (response.data['status'] == 'success') {
        _tables = (response.data['data'] as List)
            .map((item) => TableModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching tables: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTable(String number) async {
    try {
      final response = await _apiService.client.post('/tables', data: {
        'number': number,
      });
      if (response.data['status'] == 'success') {
        await fetchTables();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating table: $e');
      return false;
    }
  }

  Future<bool> deleteTable(int id) async {
    try {
      final response = await _apiService.client.delete('/tables/$id');
      if (response.data['status'] == 'success') {
        _tables.removeWhere((table) => table.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting table: $e');
      return false;
    }
  }
}

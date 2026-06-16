import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  Map<String, dynamic>? _metrics;
  List<dynamic>? _pendingTables;
  bool _isCashSessionOpen = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get metrics => _metrics;
  List<dynamic>? get pendingTables => _pendingTables;
  bool get isCashSessionOpen => _isCashSessionOpen;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/dashboard');
      
      if (response.data['status'] == 'success') {
        final data = response.data['data'];
        _metrics = data['metrics'];
        _pendingTables = data['pendingTables'];
        _isCashSessionOpen = data['isCashSessionOpen'];
      } else {
        _errorMessage = 'Failed to load dashboard data';
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? e.message ?? 'Network error';
    } catch (e) {
      _errorMessage = 'Unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

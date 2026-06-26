import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/waiter_model.dart';

class WaitersProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<WaiterModel> _waiters = [];
  List<ApplicationModel> _applications = [];
  List<AvailableWaiterModel> _availableWaiters = [];
  String _invitationLink = '';

  bool _isLoading = false;
  bool _isHiring = false;

  List<WaiterModel> get waiters => _waiters;
  List<ApplicationModel> get applications => _applications;
  List<AvailableWaiterModel> get availableWaiters => _availableWaiters;
  String get invitationLink => _invitationLink;
  bool get isHiring => _isHiring;

  bool get isLoading => _isLoading;

  Future<void> fetchWaitersData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/admin/waiters');
      if (response.data['status'] == 'success') {
        final data = response.data['data'];

        _waiters = (data['waiters'] as List)
            .map((item) => WaiterModel.fromJson(item))
            .toList();

        _applications = (data['applications'] as List)
            .map((item) => ApplicationModel.fromJson(item))
            .toList();

        _availableWaiters = (data['availableWaiters'] as List)
            .map((item) => AvailableWaiterModel.fromJson(item))
            .toList();

        _invitationLink = data['invitationLink'] ?? '';
        
        if (data['restaurant'] != null) {
          _isHiring = data['restaurant']['is_hiring'] == 1 || data['restaurant']['is_hiring'] == true;
        }
      }
    } catch (e) {
      debugPrint('Error fetching waiters data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createWaiter(String name, String email, String password) async {
    try {
      final response = await _apiService.client.post('/admin/waiters', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      if (response.data['status'] == 'success') {
        await fetchWaitersData();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating waiter: $e');
      return false;
    }
  }

  Future<bool> deleteWaiter(int id) async {
    try {
      final response = await _apiService.client.delete('/admin/waiters/$id');
      if (response.data['status'] == 'success') {
        _waiters.removeWhere((w) => w.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting waiter: $e');
      return false;
    }
  }

  Future<bool> toggleWaiterStatus(int id) async {
    try {
      final response = await _apiService.client.post('/admin/waiters/$id/toggle-status');
      if (response.data['status'] == 'success') {
        await fetchWaitersData();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling waiter status: $e');
      return false;
    }
  }

  Future<bool> processApplication(int applicationId, String status) async {
    try {
      final response = await _apiService.client.post('/admin/applications/$applicationId', data: {
        'status': status,
      });
      if (response.data['status'] == 'success') {
        await fetchWaitersData();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error processing application: $e');
      return false;
    }
  }

  Future<bool> hireWaiter(int waiterId) async {
    try {
      final response = await _apiService.client.post('/admin/waiters/$waiterId/hire');
      if (response.data['status'] == 'success') {
        await fetchWaitersData();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error hiring waiter: $e');
      return false;
    }
  }

  Future<bool> rateWaiter(int waiterId, int rating, String comment) async {
    try {
      final response = await _apiService.client.post('/admin/waiters/$waiterId/rate', data: {
        'rating': rating,
        'comment': comment,
      });
      if (response.data['status'] == 'success') {
        await fetchWaitersData();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error rating waiter: $e');
      return false;
    }
  }

  Future<void> toggleHiring() async {
    final oldState = _isHiring;
    _isHiring = !_isHiring;
    notifyListeners();
    try {
      final response = await _apiService.client.post('/restaurants/settings/toggle-hiring');
      if (response.data['status'] != 'success') {
        _isHiring = oldState;
        notifyListeners();
      }
    } catch (e) {
      _isHiring = oldState;
      notifyListeners();
      debugPrint('Error toggling hiring status: $e');
    }
  }
}

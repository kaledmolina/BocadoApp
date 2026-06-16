import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _apiService.client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final token = response.data['data']['token'];
        final userData = response.data['data']['user'];

        // Save token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        _user = User.fromJson(userData);
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Login error: ${e.response?.data}');
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<void> logout() async {
    try {
      await _apiService.client.post('/auth/logout');
    } catch (e) {
      debugPrint('Logout API error, clearing local anyway: $e');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _user = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('auth_token')) return;

    _setLoading(true);
    try {
      final response = await _apiService.client.get('/auth/me');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        _user = User.fromJson(response.data['data']);
        notifyListeners();
      }
    } catch (e) {
      // Token might be invalid or expired
      await prefs.remove('auth_token');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

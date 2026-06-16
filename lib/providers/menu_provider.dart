import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class MenuProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _products = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get products => _products;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/products');
      
      if (response.data['status'] == 'success') {
        _products = response.data['data'];
      } else {
        _errorMessage = 'Error al cargar los productos';
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? e.message ?? 'Network error';
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleAvailability(int productId) async {
    try {
      final response = await _apiService.client.post('/products/$productId/toggle');
      if (response.data['status'] == 'success') {
        // Update local state to avoid refetching
        final index = _products.indexWhere((p) => p['id'] == productId);
        if (index != -1) {
          _products[index]['is_available'] = response.data['data']['is_available'];
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      // Ignore errors for simple toggle
    }
    return false;
  }

  Future<bool> createProduct(dynamic productData) async {
    try {
      final response = await _apiService.client.post('/products', data: productData);
      if (response.data['status'] == 'success') {
        // Add the new product to the list
        _products.add(response.data['data']);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Could capture error message here
      return false;
    }
    return false;
  }
}

import 'package:flutter/foundation.dart';
import 'package:ring_sizer/models/product.dart';
import 'package:ring_sizer/services/api_service.dart';

class CatalogProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setState({bool loading = false, String? error}) {
    _isLoading = loading;
    _errorMessage = error;
    notifyListeners();
  }

  // Pour l'acheteur
  Future<void> fetchProducts({String? name, int? carat, double? priceMin, double? priceMax}) async {
    _setState(loading: true);
    try {
      final queryParams = <String, String>{
        if (name != null) 'name': name,
        if (carat != null) 'carat': carat.toString(),
        if (priceMin != null) 'priceMin': priceMin.toString(),
        if (priceMax != null) 'priceMax': priceMax.toString(),
      };
      _products = await _apiService.getProducts(queryParams);
      _setState(loading: false);
    } catch (e) {
      _setState(loading: false, error: e.toString());
    }
  }

  // Pour le vendeur
  Future<void> fetchMyProducts() async {
    _setState(loading: true);
    try {
      _products = await _apiService.getMyProducts();
      _setState(loading: false);
    } catch (e) {
      _setState(loading: false, error: e.toString());
    }
  }

  Future<bool> createProduct(Map<String, dynamic> productData) async {
    _setState(loading: true);
    try {
      final newProduct = await _apiService.createProduct(productData);
      _products.add(newProduct);
      _setState(loading: false);
      return true;
    } catch (e) {
      _setState(loading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateProduct(String productId, Map<String, dynamic> productData) async {
    _setState(loading: true);
    try {
      final updatedProduct = await _apiService.updateProduct(productId, productData);
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _setState(loading: false);
      return true;
    } catch (e) {
      _setState(loading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _apiService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

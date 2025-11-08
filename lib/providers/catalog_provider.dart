import 'package:flutter/foundation.dart';
import 'package:ring_sizer/models/product.dart';
import 'package:ring_sizer/services/catalog_service.dart';

class CatalogProvider with ChangeNotifier {
  final CatalogService _catalogService = CatalogService();

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

  Future<void> fetchProducts({String? name, int? carat, double? priceMin, double? priceMax}) async {
    _setState(loading: true);
    try {
      _products = await _catalogService.getProducts(
        name: name,
        carat: carat,
        priceMin: priceMin,
        priceMax: priceMax,
      );
      _setState(loading: false);
    } catch (e) {
      _setState(loading: false, error: e.toString());
    }
  }
}

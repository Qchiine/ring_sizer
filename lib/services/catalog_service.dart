import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ring_sizer/services/api_service.dart'; // Remplacé ApiConfig par ApiService
import 'package:ring_sizer/models/product.dart';

class CatalogService {
  final ApiService _apiService = ApiService(); // Instance de ApiService

  Future<List<Product>> getProducts({
    String? name,
    int? carat,
    double? priceMin,
    double? priceMax,
    double? weightMin,
    double? weightMax,
  }) async {
    final Map<String, String> queryParams = {
      if (name != null) 'name': name,
      if (carat != null) 'carat': carat.toString(),
      if (priceMin != null) 'priceMin': priceMin.toString(),
      if (priceMax != null) 'priceMax': priceMax.toString(),
      if (weightMin != null) 'weightMin': weightMin.toString(),
      if (weightMax != null) 'weightMax': weightMax.toString(),
    };

    final uri = Uri.parse('${ApiService.baseUrl}/catalog').replace(queryParameters: queryParams);
    final headers = await _apiService.getHeaders(); // Utilise la méthode de ApiService

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['products'];
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  Future<Product> getProductById(String productId) async {
    final headers = await _apiService.getHeaders(); // Utilise la méthode de ApiService
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/catalog/$productId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body)['product']);
    } else {
      throw Exception('Failed to load product: ${response.body}');
    }
  }
}

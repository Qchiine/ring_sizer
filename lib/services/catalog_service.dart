import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ring_sizer/config/api_config.dart';
import 'package:ring_sizer/models/product.dart';

class CatalogService {
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

    final uri = Uri.parse('${ApiConfig.baseUrl}/catalog').replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: ApiConfig.getHeaders(null));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['products'];
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  Future<Product> getProductById(String productId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/catalog/$productId'),
      headers: ApiConfig.getHeaders(null),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body)['product']);
    } else {
      throw Exception('Failed to load product: ${response.body}');
    }
  }
}

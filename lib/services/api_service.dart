import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ring_sizer/models/measurement.dart';
import 'package:ring_sizer/models/user.dart';
import '../models/product.dart';
import '../utils/storage_helper.dart';

// Le seul et unique service qui communique avec l'API.
class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  Future<Map<String, String>> getHeaders({bool useAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (useAuth) {
      final token = await StorageHelper.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ... (les autres méthodes comme getProfile, etc. restent ici)

  // ============================================
  // PROFIL (Général)
  // ============================================
  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await getHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load profile: ${response.body}');
  }

  Future<User> updateProfile(String name, String email) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: await getHeaders(),
      body: jsonEncode({'name': name, 'email': email}),
    );
    if (response.statusCode == 200) return User.fromJson(jsonDecode(response.body)['user']);
    throw Exception('Failed to update profile: ${response.body}');
  }

  // ============================================
  // MESURES
  // ============================================
  Future<List<Measurement>> getMeasurements() async {
    final response = await http.get(Uri.parse('$baseUrl/measurements'), headers: await getHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['measurements'] as List;
      return data.map((item) => Measurement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load measurements: ${response.body}');
    }
  }

  Future<Measurement> saveMeasurement(String type, double valueMm) async {
    final response = await http.post(
      Uri.parse('$baseUrl/measurements'),
      headers: await getHeaders(),
      body: jsonEncode({'type': type, 'valueMm': valueMm}),
    );
    if (response.statusCode == 201) return Measurement.fromJson(jsonDecode(response.body));
    throw Exception('Failed to save measurement: ${response.body}');
  }

  Future<int> calculateStandardSize(String type, double valueMm) async {
    final response = await http.post(
      Uri.parse('$baseUrl/measurements/calculate'),
      headers: await getHeaders(useAuth: false), // Endpoint public
      body: jsonEncode({'type': type, 'valueMm': valueMm}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['standardSize'];
    throw Exception('Failed to calculate size: ${response.body}');
  }

  // ============================================
  // CATALOGUE & PRODUITS (Unifié)
  // ============================================

  Future<List<Product>> getProducts(Map<String, String> queryParams) async {
    final uri = Uri.parse('$baseUrl/catalog').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await getHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['products'] as List;
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  Future<Product> getProductById(String productId) async {
    final response = await http.get(Uri.parse('$baseUrl/catalog/$productId'), headers: await getHeaders());
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body)['product']);
    } else {
      throw Exception('Failed to load product: ${response.body}');
    }
  }

  Future<List<Product>> getMyProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/seller/products'),
      headers: await getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['products'] as List;
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load seller products: ${response.body}');
    }
  }

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/seller/products'),
      headers: await getHeaders(),
      body: jsonEncode(productData),
    );
    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create product: ${response.body}');
    }
  }

  Future<Product> updateProduct(String productId, Map<String, dynamic> productData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/seller/products/$productId'),
      headers: await getHeaders(),
      body: jsonEncode(productData),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  Future<void> deleteProduct(String productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/seller/products/$productId'),
      headers: await getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  }

  // ============================================
  // PROFIL VENDEUR
  // ============================================
  Future<Map<String, dynamic>> getShopProfile() async {
    final response = await http.get(Uri.parse('$baseUrl/seller/shop-profile'), headers: await getHeaders());
    if (response.statusCode == 200) return {'success': true, 'data': jsonDecode(response.body)};
    return {'success': false, 'message': 'Erreur de chargement'};
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final response = await http.get(Uri.parse('$baseUrl/seller/statistics'), headers: await getHeaders());
    if (response.statusCode == 200) return {'success': true, 'data': jsonDecode(response.body)};
    return {'success': false, 'message': 'Erreur de chargement'};
  }
}

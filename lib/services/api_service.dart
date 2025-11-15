import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/product.dart';

class ApiService {
  // URL de votre backend
  static const String baseUrl = 'http://localhost:5000/api';

  // Pour Android Emulator, utilisez: http://10.0.2.2:5000/api
  // Pour téléphone physique, utilisez: http://VOTRE_IP:5000/api

  // Obtenir le token stocké
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Sauvegarder le token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Supprimer le token
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Headers avec authentification
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============================================
  // AUTHENTIFICATION
  // ============================================

  // Inscription vendeur
  Future<Map<String, dynamic>> registerSeller({
    required String name,
    required String email,
    required String password,
    required String shopName,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register-seller'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'shopName': shopName,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Erreur'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  // Connexion
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Erreur'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await deleteToken();
  }

  // ============================================
  // PROFIL BOUTIQUE
  // ============================================

  // Obtenir le profil de la boutique
  Future<Map<String, dynamic>> getShopProfile() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/seller/shop-profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Erreur de chargement'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // Mettre à jour le profil
  Future<Map<String, dynamic>> updateShopProfile({
    String? shopName,
    String? description,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/seller/shop-profile'),
        headers: headers,
        body: jsonEncode({
          if (shopName != null) 'shopName': shopName,
          if (description != null) 'description': description,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Erreur de mise à jour'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ============================================
  // PRODUITS
  // ============================================

  // Créer un produit (sans image pour l'instant)
  Future<Map<String, dynamic>> createProduct({
    required String title,
    required String description,
    required int carat,
    required double weight,
    required double price,
    required int stock,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/seller/products'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'carat': carat,
          'weight': weight,
          'price': price,
          'stock': stock,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Erreur'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // Obtenir tous les produits du vendeur
  Future<Map<String, dynamic>> getMyProducts() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/seller/products'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Product> products = (data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        return {'success': true, 'products': products};
      } else {
        return {'success': false, 'message': 'Erreur de chargement'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // Obtenir un produit
  Future<Map<String, dynamic>> getProduct(String productId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/seller/products/$productId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Erreur de chargement'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // Modifier un produit
  Future<Map<String, dynamic>> updateProduct(
      String productId, {
        String? title,
        String? description,
        int? carat,
        double? weight,
        double? price,
        int? stock,
      }) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/seller/products/$productId'),
        headers: headers,
        body: jsonEncode({
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (carat != null) 'carat': carat,
          if (weight != null) 'weight': weight,
          if (price != null) 'price': price,
          if (stock != null) 'stock': stock,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Erreur de mise à jour'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // Supprimer un produit
  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/seller/products/$productId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Produit supprimé'};
      } else {
        return {'success': false, 'message': 'Erreur de suppression'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // Mettre à jour le stock
  Future<Map<String, dynamic>> updateStock(
      String productId,
      int stock,
      ) async {
    try {
      final headers = await getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/seller/products/$productId/stock'),
        headers: headers,
        body: jsonEncode({'stock': stock}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Erreur de mise à jour'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/seller/statistics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Erreur de chargement'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
}
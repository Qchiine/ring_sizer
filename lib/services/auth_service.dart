import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ring_sizer/config/api_config.dart';
import 'package:ring_sizer/models/user.dart';
import 'package:ring_sizer/utils/storage_helper.dart';

class AuthService {
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: ApiConfig.getHeaders(null),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        await StorageHelper.saveToken(token);
      }
      return {'token': token, 'user': User.fromJson(data['user'])};
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: ApiConfig.getHeaders(null),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        await StorageHelper.saveToken(token);
      }
      return {'token': token, 'user': User.fromJson(data['user'])};
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<void> logout() async {
    await StorageHelper.deleteToken();
  }
}

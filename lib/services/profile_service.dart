import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ring_sizer/config/api_config.dart';
import 'package:ring_sizer/models/user.dart';
import 'package:ring_sizer/utils/storage_helper.dart';

class ProfileService {
  Future<Map<String, dynamic>> getProfile() async {
    final token = await StorageHelper.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: ApiConfig.getHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile: ${response.body}');
    }
  }

  Future<User> updateProfile(String name, String email) async {
    final token = await StorageHelper.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: ApiConfig.getHeaders(token),
      body: jsonEncode({'name': name, 'email': email}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)['user']);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }
}

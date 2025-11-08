import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ring_sizer/config/api_config.dart';
import 'package:ring_sizer/models/measurement.dart';
import 'package:ring_sizer/utils/storage_helper.dart';

class MeasurementService {
  Future<Measurement> saveMeasurement(String type, double valueMm) async {
    final token = await StorageHelper.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/measurements'),
      headers: ApiConfig.getHeaders(token),
      body: jsonEncode({'type': type, 'valueMm': valueMm}),
    );

    if (response.statusCode == 201) {
      return Measurement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save measurement: ${response.body}');
    }
  }

  Future<int> calculateStandardSize(String type, double valueMm) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/measurements/calculate'),
      headers: ApiConfig.getHeaders(null), // Endpoint public
      body: jsonEncode({'type': type, 'valueMm': valueMm}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['standardSize'];
    } else {
      throw Exception('Failed to calculate size: ${response.body}');
    }
  }

  Future<List<Measurement>> getMeasurements() async {
    final token = await StorageHelper.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/measurements'),
      headers: ApiConfig.getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['measurements'];
      return data.map((item) => Measurement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load measurements: ${response.body}');
    }
  }
}

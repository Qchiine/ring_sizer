
import 'package:flutter/foundation.dart';
import 'package:ring_sizer/models/measurement.dart';
import 'package:ring_sizer/models/user.dart';
import 'package:ring_sizer/services/api_service.dart'; // Le seul service

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _user;
  List<Measurement> _measurements = [];
  Map<String, dynamic>? _shopProfile;
  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  List<Measurement> get measurements => _measurements;
  Map<String, dynamic>? get shopProfile => _shopProfile;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setState({bool loading = false, String? error}) {
    _isLoading = loading;
    _errorMessage = error;
    notifyListeners();
  }

  // Pour l'acheteur
  Future<void> fetchProfile() async {
    _setState(loading: true);
    try {
      final profileData = await _apiService.getProfile();
      _user = User.fromJson(profileData['user']);
      // L'API profile renvoie aussi les mesures
      final List<dynamic> measurementsData = profileData['mesures'] ?? [];
      _measurements = measurementsData.map((data) => Measurement.fromJson(data)).toList();
      _setState(loading: false);
    } catch (e) {
      _setState(loading: false, error: e.toString());
    }
  }

  // Pour le vendeur
  Future<void> fetchShopProfile() async {
    _setState(loading: true);
    try {
      final results = await Future.wait([
        _apiService.getShopProfile(),
        _apiService.getStatistics(),
      ]);

      if (results[0]['success']) {
        _shopProfile = results[0]['data'];
      }
      if (results[1]['success']) {
        _statistics = results[1]['data'];
      }
      // On récupère aussi les infos de base de l'utilisateur vendeur
      final profileData = await _apiService.getProfile();
      _user = User.fromJson(profileData['user']);
      
      _setState(loading: false);
    } catch (e) {
      _setState(loading: false, error: e.toString());
    }
  }

  // Actions pour les mesures
  Future<int?> calculateSize(String type, double valueMm) async {
    try {
      final size = await _apiService.calculateStandardSize(type, valueMm);
      return size;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> saveNewMeasurement(String type, double valueMm) async {
    try {
      final newMeasurement = await _apiService.saveMeasurement(type, valueMm);
      _measurements.add(newMeasurement);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:ring_sizer/models/measurement.dart';
import 'package:ring_sizer/models/user.dart';
import 'package:ring_sizer/services/profile_service.dart';
import 'package:ring_sizer/services/measurement_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final MeasurementService _measurementService = MeasurementService();

  User? _user;
  List<Measurement> _measurements = [];
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  List<Measurement> get measurements => _measurements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setState({bool loading = false, String? error}) {
    _isLoading = loading;
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    _setState(loading: true);
    try {
      final profileData = await _profileService.getProfile();
      _user = User.fromJson(profileData['user']);
      final List<dynamic> measurementsData = profileData['mesures'] ?? [];
      _measurements = measurementsData.map((data) => Measurement.fromJson(data)).toList();
      _setState(loading: false);
    } catch (e) {
      _setState(loading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile(String name, String email) async {
    _setState(loading: true);
    try {
      final updatedUser = await _profileService.updateProfile(name, email);
      _user = updatedUser;
      _setState(loading: false);
      return true;
    } catch (e) {
      _setState(loading: false, error: e.toString());
      return false;
    }
  }
  
  Future<void> fetchMeasurements() async {
    // Cette méthode peut être appelée si le profil ne charge pas les mesures par défaut
    try {
      _measurements = await _measurementService.getMeasurements();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}

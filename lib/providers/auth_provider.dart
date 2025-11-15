import 'package:flutter/foundation.dart';
import 'package:ring_sizer/models/user.dart';
import 'package:ring_sizer/services/auth_service.dart';
import 'package:ring_sizer/utils/storage_helper.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    _token = await StorageHelper.getToken();
    if (_token != null) {
      // Idéalement, ici, vous devriez aussi récupérer les informations de l'utilisateur
      // en utilisant un endpoint comme /api/profile pour vous assurer que le token est valide.
      // Pour l'instant, nous considérons le token comme suffisant.
      notifyListeners();
    }
  }

  void _setState({bool loading = false, String? error}) {
    _isLoading = loading;
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setState(loading: true);
    try {
      final response = await _authService.login(email, password);
      _user = response['user'];
      _token = response['token'];
      _setState(loading: false);
      return true;
    } catch (e) {
      _setState(loading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setState(loading: true);
    try {
      final response = await _authService.register(name, email, password);
      _user = response['user'];
      _token = response['token'];
      _setState(loading: false);
      return true;
    } catch (e) {
      _setState(loading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _authService.logout();
    notifyListeners();
  }
}

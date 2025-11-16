import 'package:flutter/foundation.dart';
import 'package:ring_sizer/models/user.dart';
import 'package:ring_sizer/services/auth_service.dart';
import 'package:ring_sizer/utils/storage_helper.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _token;
  String? _userRole; // Ajout du rôle de l'utilisateur
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _token;
  String? get userRole => _userRole; // Getter pour le rôle
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    _token = await StorageHelper.getToken();
    _userRole = await StorageHelper.getRole(); // Essayer de récupérer le rôle
    if (_token != null) {
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
      _userRole = _user?.role; // Récupérer le rôle de l'utilisateur

      await StorageHelper.saveToken(_token!); // Sauvegarder le token
      await StorageHelper.saveRole(_userRole!); // Sauvegarder le rôle

      _setState(loading: false);
      return true;
    } catch (e) {
      _setState(loading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String role) async {
    _setState(loading: true);
    try {
      final response = await _authService.register(name, email, password, role);
      _user = response['user'];
      _token = response['token'];
      _userRole = _user?.role;

      await StorageHelper.saveToken(_token!); // Sauvegardar le token
      await StorageHelper.saveRole(_userRole!); // Sauvegardar le rôle

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
    _userRole = null;
    await _authService.logout();
    await StorageHelper.clear(); // Nettoyer le stockage
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:ring_sizer/services/api_service.dart';
import 'login_screen.dart';
import '../dashboard/dashboard_screen.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({Key? key}) : super(key: key);

  @override
  _CheckAuthScreenState createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Petite pause pour ne pas avoir un flash si la vérification est trop rapide
    await Future.delayed(const Duration(milliseconds: 500));
    
    final apiService = ApiService();
    final token = await apiService.getToken();

    if (mounted) {
      if (token != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Vérification en cours...'),
          ],
        ),
      ),
    );
  }
}

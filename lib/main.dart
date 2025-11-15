import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  // 1. S'assurer que Flutter est prêt
  WidgetsFlutterBinding.ensureInitialized();

  bool isLoggedIn = false;

  // 2. Vérifier si on n'est PAS sur une plateforme desktop ou web
  // Le plugin shared_preferences est principalement pour mobile.
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
    // Logique pour mobile : on vérifie le token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    isLoggedIn = token != null;
  }
  // Pour Windows, Linux, ou le web, on ne vérifie pas le token et on considère
  // l'utilisateur comme déconnecté. Cela évite le crash du plugin.

  // 3. Lancer l'application avec la bonne page
  runApp(RingSizerSellerApp(isLoggedIn: isLoggedIn));
}

class RingSizerSellerApp extends StatelessWidget {
  final bool isLoggedIn;

  const RingSizerSellerApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ring Sizer - Vendeur',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      // Si l'utilisateur n'est pas connecté (ou si on est sur Windows),
      // on affiche la page de connexion. Sinon, le tableau de bord.
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}

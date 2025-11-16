import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ring_sizer/providers/auth_provider.dart';
import 'package:ring_sizer/providers/catalog_provider.dart';
import 'package:ring_sizer/providers/profile_provider.dart';
import 'package:ring_sizer/screens/auth/login_screen.dart';
import 'package:ring_sizer/features/catalog/screens/catalog_screen.dart'; // Correction du chemin
import 'package:ring_sizer/screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) => ProfileProvider(),
          update: (context, auth, previousProfile) => previousProfile!..fetchProfile(),
        ),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
      ],
      child: MaterialApp(
        title: 'Ring Sizer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute les changements dans AuthProvider
    final auth = Provider.of<AuthProvider>(context);

    if (auth.isAuthenticated) {
      // Si l'utilisateur est un vendeur, on montre le tableau de bord
      if (auth.userRole == 'seller') {
        return const DashboardScreen();
      }
      // Sinon (on suppose que c'est un acheteur), on montre le catalogue
      else {
        return const CatalogScreen();
      }
    } else {
      // Si non authentifié, on montre l'écran de connexion
      return const LoginScreen();
    }
  }
}

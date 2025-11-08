import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ring_sizer/providers/auth_provider.dart';
import 'package:ring_sizer/providers/catalog_provider.dart';
import 'package:ring_sizer/providers/profile_provider.dart';
import 'package:ring_sizer/screens/auth/login_screen.dart';
import 'package:ring_sizer/screens/catalog/catalog_screen.dart'; // Nous allons créer cet écran bientôt

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
          update: (context, auth, previousProfile) => previousProfile!..fetchProfile(), // Met à jour le profil quand l'auth change
        ),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Ring Sizer',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: auth.isAuthenticated
              ? CatalogScreen() // Si authentifié, va au catalogue
              : LoginScreen(),    // Sinon, va à l'écran de connexion
        ),
      ),
    );
  }
}

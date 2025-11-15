import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ring_sizer/providers/auth_provider.dart';
import 'package:ring_sizer/providers/catalog_provider.dart';
import 'package:ring_sizer/screens/profile/profile_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key}); // Ajout de la clé

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    // Utiliser addPostFrameCallback pour appeler le provider après la construction du widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Vérifier si le widget est toujours monté avant d'appeler le provider
      if (mounted) {
        Provider.of<CatalogProvider>(context, listen: false).fetchProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: Consumer<CatalogProvider>(
        builder: (ctx, catalog, child) {
          if (catalog.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (catalog.errorMessage != null) {
            return Center(child: Text('Une erreur est survenue: ${catalog.errorMessage}'));
          }

          if (catalog.products.isEmpty) {
            return const Center(child: Text('Aucun produit trouvé.'));
          }

          return ListView.builder(
            itemCount: catalog.products.length,
            itemBuilder: (ctx, i) {
              final product = catalog.products[i];
              return ListTile(
                leading: Image.network(product.imageUrl, width: 50, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.error)),
                title: Text(product.title),
                subtitle: Text('${product.price} € - ${product.weight}g'),
                // TODO: Ajouter la navigation vers la fiche produit détaillée
              );
            },
          );
        },
      ),
    );
  }
}

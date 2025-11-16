import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ring_sizer/providers/auth_provider.dart';
import 'package:ring_sizer/providers/catalog_provider.dart';

// Écran principal pour l'acheteur, affichant les produits disponibles.

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    // Au démarrage de l'écran, on demande au provider de charger les produits.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CatalogProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        actions: [
          // TODO: Ajouter des actions pertinentes pour l'acheteur (ex: Panier, Profil)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Déconnexion propre via le AuthProvider
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: Consumer<CatalogProvider>(
        builder: (ctx, catalog, child) {
          // Affiche un indicateur de chargement
          if (catalog.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Affiche un message d'erreur s'il y en a un
          if (catalog.errorMessage != null) {
            return Center(child: Text('Une erreur est survenue: ${catalog.errorMessage}'));
          }

          // Affiche un message si aucun produit n'est trouvé
          if (catalog.products.isEmpty) {
            return const Center(child: Text('Aucun produit disponible pour le moment.'));
          }

          // Affiche la liste des produits
          return ListView.builder(
            itemCount: catalog.products.length,
            itemBuilder: (ctx, i) {
              final product = catalog.products[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    // Affiche l'image du produit ou une icône par défaut
                    child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                        ? Image.network(
                            product.imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 60);
                            },
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(Icons.diamond_outlined, size: 30),
                          ),
                  ),
                  title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${product.price.toStringAsFixed(2)} € - ${product.weight}g'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Naviguer vers l'écran de détail du produit
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

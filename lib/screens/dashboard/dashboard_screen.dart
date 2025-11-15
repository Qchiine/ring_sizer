import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../products/products_list_screen.dart';
import '../products/add_product_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    final result = await _apiService.getStatistics();

    if (mounted) {
      setState(() {
        if (result['success'] && result['data'] is Map<String, dynamic>) {
          _stats = result['data'];
        } else {
          // Si l'appel échoue ou que les données sont invalides, on utilise des valeurs par défaut.
          _stats = {
            'totalProducts': 0,
            'totalOrders': 0,
            'totalRevenue': 0.0,
            'averageRating': 0.0,
          };
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Colors.deepPurple.shade400,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadStatistics,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bonjour, 👋',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Ma Boutique d\'Or',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined,
                                  color: Colors.white, size: 28),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats Cards
                SliverToBoxAdapter(
                  child: _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            children: [
                              _buildStatCard(
                                '${_stats['totalProducts'] ?? 0}',
                                'Produits',
                                Icons.inventory_2,
                                Colors.blue,
                              ),
                              _buildStatCard(
                                '${_stats['totalOrders'] ?? 0}',
                                'Commandes',
                                Icons.shopping_cart,
                                Colors.orange,
                              ),
                              _buildStatCard(
                                '${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(0)}€',
                                'Revenus',
                                Icons.attach_money,
                                Colors.green,
                              ),
                              _buildStatCard(
                                '${(_stats['averageRating'] ?? 0.0).toStringAsFixed(1)}⭐',
                                'Note',
                                Icons.star,
                                Colors.amber,
                              ),
                            ],
                          ),
                        ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),

                // Actions rapides
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Actions rapides',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              children: [
                                _buildActionButton(
                                  context,
                                  'Mes Produits',
                                  Icons.inventory_2,
                                  Colors.blue,
                                  const ProductsListScreen(),
                                ),
                                _buildActionButton(
                                  context,
                                  'Ajouter Produit',
                                  Icons.add_circle,
                                  Colors.green,
                                  const AddProductScreen(),
                                ),
                                _buildActionButton(
                                  context,
                                  'Commandes',
                                  Icons.shopping_bag,
                                  Colors.orange,
                                  null,
                                ),
                                _buildActionButton(
                                  context,
                                  'Profil',
                                  Icons.person,
                                  Colors.purple,
                                  const ProfileScreen(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String label,
      IconData icon,
      Color color,
      Widget? screen,
      ) {
    return InkWell(
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fonctionnalité à venir!')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

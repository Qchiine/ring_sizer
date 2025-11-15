import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    // Charger le profil et les stats en parallèle
    final results = await Future.wait([
      _apiService.getShopProfile(),
      _apiService.getStatistics(),
    ]);

    if (mounted) {
      setState(() {
        if (results[0]['success']) {
          _profileData = results[0]['data'];
        }
        if (results[1]['success']) {
          _stats = results[1]['data'];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header avec gradient
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade600,
                      Colors.deepPurple.shade800
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                Text('Modification à venir!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.store,
                        size: 50,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Nom boutique
                    Text(
                      _profileData?['shopName'] ?? 'Ma Boutique',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _profileData?['email'] ?? 'email@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn(
                          '${_stats?['totalProducts'] ?? 0}',
                          'Produits',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildStatColumn(
                          '${_stats?['totalOrders'] ?? 0}',
                          'Ventes',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildStatColumn(
                          '${(_stats?['averageRating'] ?? 0).toStringAsFixed(1)}⭐',
                          'Note',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Menu
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text(
                    'Paramètres',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildMenuItem(
                    icon: Icons.edit,
                    title: 'Modifier le profil',
                    color: Colors.blue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Modification à venir!'),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.store,
                    title: 'Infos boutique',
                    color: Colors.orange,
                    onTap: () {
                      _showShopInfoDialog();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.bar_chart,
                    title: 'Statistiques',
                    color: Colors.green,
                    onTap: () {
                      _showStatsDialog();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications à venir!'),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Aide & Support',
                    color: Colors.teal,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support à venir!'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bouton déconnexion
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Déconnexion',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showShopInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Infos Boutique'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Nom', _profileData?['shopName'] ?? '-'),
            const SizedBox(height: 10),
            _buildInfoRow('Email', _profileData?['email'] ?? '-'),
            const SizedBox(height: 10),
            _buildInfoRow(
              'Description',
              _profileData?['description'] ?? 'Aucune description',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Produits', '${_stats?['totalProducts'] ?? 0}'),
            _buildStatRow('Commandes', '${_stats?['totalOrders'] ?? 0}'),
            _buildStatRow(
              'Revenus',
              '${(_stats?['totalRevenue'] ?? 0).toStringAsFixed(2)}€',
            ),
            _buildStatRow(
              'Note moyenne',
              '${(_stats?['averageRating'] ?? 0).toStringAsFixed(1)} ⭐',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:provider/provider.dart';
import 'package:ring_sizer/providers/profile_provider.dart';
import 'package:ring_sizer/screens/measurements/measurements_screen.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key}); // Ajout de la clé

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = profileProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.straighten), // Icône pour les mesures
            onPressed: () {
               Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MeasurementsScreen()),
              );
            },
          )
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        // TODO: Ajouter un bouton pour modifier le profil
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text('Mes Mesures', style: Theme.of(context).textTheme.titleLarge), // Correction ici
                  Expanded(
                    child: ListView.builder(
                      itemCount: profileProvider.measurements.length,
                      itemBuilder: (ctx, i) {
                        final measure = profileProvider.measurements[i];
                        return ListTile(
                          title: Text('${measure.type.capitalize()} - ${measure.standardSize}'),
                          subtitle: Text('${measure.valueMm} mm'),
                          trailing: Text(DateFormat('dd/MM/yyyy').format(measure.date)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Petite extension pour mettre la première lettre en majuscule
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return "";
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

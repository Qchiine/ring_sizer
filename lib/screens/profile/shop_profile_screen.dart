import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ring_sizer/providers/auth_provider.dart';
import 'package:ring_sizer/providers/profile_provider.dart';
import '../auth/login_screen.dart';

// Ce fichier est maintenant dédié au profil du VENDEUR.

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({Key? key}) : super(key: key);

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  @override
  void initState() {
    super.initState();
    // On demande au ProfileProvider de charger les données de la boutique
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchShopProfile();
    });
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

    if (confirm == true && mounted) {
      // On utilise AuthProvider pour se déconnecter
      Provider.of<AuthProvider>(context, listen: false).logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (ctx, provider, _) {
        final profileData = provider.shopProfile;
        final stats = provider.statistics;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildHeader(context, provider.user, profileData, stats),
                _buildMenu(context, profileData, stats),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, Map<String, dynamic>? profileData, Map<String, dynamic>? stats) {
    return SliverToBoxAdapter(
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () { /* TODO: Naviguer vers un écran de modification */ },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: const Icon(Icons.store, size: 50, color: Colors.deepPurple),
            ),
            const SizedBox(height: 15),
            Text(
              profileData?['shopName'] ?? 'Ma Boutique',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              user?.email ?? 'email@example.com',
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('${stats?['totalProducts'] ?? 0}', 'Produits'),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                _buildStatColumn('${stats?['totalOrders'] ?? 0}', 'Ventes'),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                _buildStatColumn('${(stats?['averageRating'] ?? 0).toStringAsFixed(1)}⭐', 'Note'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, Map<String, dynamic>? profileData, Map<String, dynamic>? stats) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const Text('Paramètres', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildMenuItem(icon: Icons.edit, title: 'Modifier le profil', color: Colors.blue, onTap: () {}),
          _buildMenuItem(icon: Icons.store, title: 'Infos boutique', color: Colors.orange, onTap: () => _showShopInfoDialog(context, profileData)),
          _buildMenuItem(icon: Icons.bar_chart, title: 'Statistiques', color: Colors.green, onTap: () => _showStatsDialog(context, stats)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Déconnexion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ]),
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

  void _showShopInfoDialog(BuildContext context, Map<String, dynamic>? profileData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Infos Boutique'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Nom', profileData?['shopName'] ?? '-'),
            const SizedBox(height: 10),
            _buildInfoRow('Email', Provider.of<ProfileProvider>(context, listen: false).user?.email ?? '-'),
            const SizedBox(height: 10),
            _buildInfoRow(
              'Description',
              profileData?['description'] ?? 'Aucune description',
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

  void _showStatsDialog(BuildContext context, Map<String, dynamic>? stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Produits', '${stats?['totalProducts'] ?? 0}'),
            _buildStatRow('Commandes', '${stats?['totalOrders'] ?? 0}'),
            _buildStatRow(
              'Revenus',
              '${(stats?['totalRevenue'] ?? 0).toStringAsFixed(2)}€',
            ),
            _buildStatRow(
              'Note moyenne',
              '${(stats?['averageRating'] ?? 0).toStringAsFixed(1)} ⭐',
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

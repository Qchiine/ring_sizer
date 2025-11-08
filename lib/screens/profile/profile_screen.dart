import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ring_sizer/providers/profile_provider.dart';
import 'package:ring_sizer/screens/measurements/measurements_screen.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
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
                  Text('Mes Mesures', style: Theme.of(context).textTheme.headline6),
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
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

import 'package:flutter/material.dart';

class ClinicCard extends StatelessWidget {
  final String name;
  final double distanceKm;

  const ClinicCard({super.key, required this.name, required this.distanceKm});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.local_hospital, color: Colors.blue),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${distanceKm.toStringAsFixed(1)} km away'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Viewing details for $name')));
        },
      ),
    );
  }
}

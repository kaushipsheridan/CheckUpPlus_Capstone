import 'package:checkupplus_capstone/models/clinic_model.dart';
import 'package:flutter/material.dart';

class ClinicCard extends StatelessWidget {
  final Clinic clinic;
  final double distanceKm;

  const ClinicCard({super.key, required this.clinic, required this.distanceKm});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_hospital, color: Colors.blue),
        title: Text(clinic.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (clinic.specialty.isNotEmpty) Text(clinic.specialty),
            if (clinic.address.isNotEmpty) Text(clinic.address),
            if (clinic.phone.isNotEmpty) Text('📞 ${clinic.phone}'),
            Text('📍 ${distanceKm.toStringAsFixed(1)} km away'),
          ],
        ),
      ),
    );
  }
}

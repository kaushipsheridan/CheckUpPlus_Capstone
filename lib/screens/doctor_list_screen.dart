import 'package:flutter/material.dart';
import 'doctor_model.dart'; // Import the data models

class DoctorListScreen extends StatelessWidget {
  final String category;

  // The key fix: This screen MUST accept a category string
  const DoctorListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Filter the mock data based on the category passed to this screen
    final doctors = getDoctorsForCategory(category);

    return Scaffold(
      appBar: AppBar(title: Text('$category Specialists')),
      body: doctors.isEmpty
          ? Center(
              child: Text(
                'No $category specialists found nearby.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                return DoctorCard(doctor: doctors[index]);
              },
            ),
    );
  }
}

/// A custom card widget to display a single doctor's details
class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar/Icon placeholder
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 15),
            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specialty,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    doctor.clinicName,
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('${doctor.rating.toStringAsFixed(1)} Rating'),
                      const SizedBox(width: 15),
                      Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 18),
                      const SizedBox(width: 4),
                      Text('${doctor.distanceKm} km away'),
                    ],
                  ),
                  if (doctor.isUrgentCare)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'Urgent Care Available',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder for booking action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Starting booking flow for ${doctor.name}')),
                  );
                },
                child: const Text('Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
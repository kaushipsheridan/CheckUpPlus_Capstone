import 'package:flutter/material.dart';

class NearbyClinicsMapScreen extends StatelessWidget {
  const NearbyClinicsMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Clinics Map')),
      body: const Center(
        child: Text(
          'Google Maps integration with filters for walk-in clinics.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

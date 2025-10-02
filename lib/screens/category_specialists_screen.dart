import 'package:flutter/material.dart';

class CategorySpecialistsScreen extends StatelessWidget {
  final String category;
  const CategorySpecialistsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$category Clinics')),
      body: Center(
        child: Text(
          'Nearest clinics and specialists for $category will be displayed here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

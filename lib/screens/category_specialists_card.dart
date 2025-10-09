import 'package:flutter/material.dart';
import 'doctor_model.dart'; 
import 'doctor_list_screen.dart'; // Import the next screen

/// The screen showing a grid of all medical categories.
class CategorySpecialistsScreen extends StatelessWidget {
  const CategorySpecialistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find a Specialist or Urgent Care',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 columns
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8, // Adjust item height
                ),
                itemCount: mockCategories.length,
                itemBuilder: (context, index) {
                  final category = mockCategories[index];
                  return InkWell(
                    onTap: () {
                      // Correct navigation: Go to the doctor list for the tapped category
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DoctorListScreen(category: category.title),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circular background for the icon
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category.icon,
                            size: 30,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Category title
                        Text(
                          category.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
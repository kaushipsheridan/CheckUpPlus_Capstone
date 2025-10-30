import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'doctor_list_screen.dart'; // Import the next screen
import '../authentication/appointment_model.dart'; // Import for the Appointment class

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
                    // *** UPDATED onTap ***
                    onTap: () async {
                      // Make it async
                      // 1. Push the doctor list and wait for a result
                      final newAppointment = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              DoctorListScreen(category: category.title),
                        ),
                      );

                      // 2. Check if we got an appointment back
                      if (newAppointment != null &&
                          newAppointment is Appointment) {
                        // 3. If yes, pop *this* screen and pass the result back
                        //    to BookingsScreen
                        Navigator.of(context).pop(newAppointment);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circular background for the icon
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
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

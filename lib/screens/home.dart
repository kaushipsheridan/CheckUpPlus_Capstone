import 'package:checkupplus_capstone/screens/chat.dart';
import 'package:checkupplus_capstone/widgets/nearby_clinics_map_screen.dart';
import 'package:checkupplus_capstone/widgets/speciality_grid.dart';
import 'package:flutter/material.dart';
import '../widgets/ai_cta_card.dart';
import '../widgets/clinic_card.dart';
import 'category_specialists_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double padding = 16.0;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Current Location: Brampton, ON',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: padding),

            _buildSearchBar(context),
            const SizedBox(height: padding),

            AiCtaCard(
              onStartChatTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              ),
            ),
            const SizedBox(height: padding),

            const Text(
              'Doctor Speciality',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SpecialtyGrid(
              onCategoryTap: (category) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategorySpecialistsScreen(category: category),
                ),
              ),
            ),
            const SizedBox(height: padding),

            _buildNearbyClinicsHeader(context),
            const SizedBox(height: 8),

            const ClinicCard(name: 'Brampton Walk-in Clinic', distanceKm: 1.2),
            const ClinicCard(name: 'Emergency Urgent Care', distanceKm: 3.5),
            const ClinicCard(name: 'Family Health Center', distanceKm: 4.8),
          ],
        ),
      ),
    );
  }

  // Helper methods remain local to the screen
  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Search screen navigation placeholder.'),
          ),
        );
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Search for nearest clinic based on the location',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyClinicsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Nearby Clinics (within 5km)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NearbyClinicsMapScreen()),
          ),
          child: const Text(
            'See All',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

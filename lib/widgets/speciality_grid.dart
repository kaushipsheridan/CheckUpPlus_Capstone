import 'package:flutter/material.dart';

class SpecialtyGrid extends StatelessWidget {
  final ValueChanged<String> onCategoryTap;

  const SpecialtyGrid({super.key, required this.onCategoryTap});

  final List<Map<String, dynamic>> specialties = const [
    {'name': 'Cardiology', 'icon': Icons.favorite},
    {'name': 'Dermatology', 'icon': Icons.face},
    {'name': 'Pediatrics', 'icon': Icons.child_care},
    {'name': 'Orthopedics', 'icon': Icons.accessible},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          final specialty = specialties[index];
          return GestureDetector(
            onTap: () => onCategoryTap(specialty['name']),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(specialty['icon'], color: Colors.blue, size: 30),
                  const SizedBox(height: 5),
                  Text(
                    specialty['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

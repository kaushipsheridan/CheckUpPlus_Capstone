// widgets/speciality_grid.dart (or where you placed it)

import 'package:flutter/material.dart';
import '../models/doctor_model.dart';

class SpecialtyGrid extends StatelessWidget {
  // This takes a callback function when an item in the grid is tapped
  final Function(String category) onCategoryTap;

  const SpecialtyGrid({super.key, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    // We only show a limited number of categories on the Home screen
    // The CategorySpecialistsScreen shows all of them.
    final limitedCategories = mockCategories.take(8).toList();

    return GridView.builder(
      // Important to use these settings when embedding a GridView inside a SingleChildScrollView
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: limitedCategories.length,
      itemBuilder: (context, index) {
        final category = limitedCategories[index];
        return InkWell(
          onTap: () => onCategoryTap(category.title),
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
    );
  }
}
